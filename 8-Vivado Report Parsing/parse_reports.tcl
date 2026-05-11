# ============================================================
# Vivado Report Parser
# Project : AXI Image Processing Pipeline (Zynq-7020)
# Author  : ayengec
# ============================================================
# Parses:
#   - sample_reports/timing_summary.rpt
#   - sample_reports/utilization.rpt
# Outputs:
#   - logs/report_summary.txt
#   - logs/timing_details.txt
#   - logs/utilization_details.txt
# ============================================================

# ----------------------------------------
# Configuration
# ----------------------------------------
set timing_rpt   "./sample_reports/timing_summary.rpt"
set util_rpt     "./sample_reports/utilization.rpt"
set log_dir      "./logs"

file mkdir $log_dir

set summary_log [open "$log_dir/report_summary.txt"      w]
set timing_log  [open "$log_dir/timing_details.txt"      w]
set util_log    [open "$log_dir/utilization_details.txt" w]

# ============================================================
# HELPER PROCEDURES
# ============================================================

# Print to both console and a log file
proc log_puts {fd msg} {
    puts $fd $msg
    puts $msg
}

# Extract a value using regex from a line
# Returns the first capture group or "" if not found
proc extract_value {line pattern} {
    if {[regexp $pattern $line match val]} {
        return [string trim $val]
    }
    return ""
}

# Print a horizontal divider
proc divider {fd} {
    log_puts $fd "--------------------------------------------------------------"
}

# ============================================================
# TIMING SUMMARY PARSER
# ============================================================
proc parse_timing {filename timing_log summary_log} {

    log_puts $timing_log "TIMING SUMMARY REPORT"
    log_puts $timing_log "Parsed from: $filename"
    divider $timing_log

    set fd [open $filename r]

    # State flags
    set in_design_timing 0
    set in_intra_clock   0
    set in_inter_clock   0
    set in_max_path      0

    # Collected values
    set wns         "N/A"
    set tns         "N/A"
    set tns_failing "N/A"
    set whs         "N/A"
    set ths         "N/A"
    set design_name "N/A"
    set device      "N/A"

    set clocks      {}
    set violations  {}

    while {[gets $fd line] >= 0} {

        # ---- Header info ----
        if {[regexp {^\| Design\s+:\s+(\S+)} $line -> val]} {
            set design_name $val
        }
        if {[regexp {^\| Device\s+:\s+(\S+)} $line -> val]} {
            set device $val
        }

        # ---- Design Timing Summary table ----
        if {[string match "*Design Timing Summary*" $line]} {
            set in_design_timing 1
        }
        if {$in_design_timing && [regexp \
            {^\s+([-\d.]+)\s+([-\d.]+)\s+(\d+)\s+(\d+)\s+([-\d.]+)\s+([-\d.]+)\s+(\d+)\s+(\d+)} \
            $line -> w_wns w_tns w_tns_fail w_tns_tot w_whs w_ths w_ths_fail w_ths_tot]} {

            set wns         $w_wns
            set tns         $w_tns
            set tns_failing $w_tns_fail
            set whs         $w_whs
            set ths         $w_ths
            set in_design_timing 0
        }

        # ---- Clock Summary ----
        if {[string match "*Clock Summary*" $line]} {
            set in_clk 1
        }
        if {[info exists in_clk] && $in_clk} {
            # Match lines like: clk_100MHz    {0.000 5.000}   10.000   100.000
            if {[regexp \
                {^(\w+)\s+\{[\d. ]+\}\s+([\d.]+)\s+([\d.]+)} \
                $line -> clk_name period freq]} {
                lappend clocks [list $clk_name $period $freq]
            }
            if {[string match "*Intra Clock*" $line]} {
                set in_clk 0
            }
        }

        # ---- Intra Clock per-clock violations ----
        if {[string match "*Intra Clock Table*" $line]} {
            set in_intra_clock 1
        }
        if {$in_intra_clock} {
            if {[regexp \
                {^(\w+)\s+([-\d.]+)\s+([-\d.]+)\s+(\d+)\s+(\d+)\s+([-\d.]+)} \
                $line -> clk_n i_wns i_tns i_fail i_tot i_whs]} {
                lappend violations [list $clk_n $i_wns $i_tns $i_fail $i_tot]
            }
            if {[string match "*Inter Clock*" $line]} {
                set in_intra_clock 0
            }
        }

        # ---- Slack violated paths (max delay section) ----
        if {[regexp {Slack \(VIOLATED\)\s+:\s+([-\d.]+)ns} $line -> slack_val]} {
            log_puts $timing_log "  \[!\] Violated path slack: ${slack_val}ns"
        }
    }

    close $fd

    # ----------------------------------------
    # Write timing log
    # ----------------------------------------
    log_puts $timing_log ""
    log_puts $timing_log "Design : $design_name"
    log_puts $timing_log "Device : $device"
    divider $timing_log

    log_puts $timing_log ""
    log_puts $timing_log "=== Overall Timing ==="
    log_puts $timing_log "  WNS (Worst Negative Slack) : ${wns} ns"
    log_puts $timing_log "  TNS (Total Negative Slack) : ${tns} ns"
    log_puts $timing_log "  Failing Endpoints          : $tns_failing"
    log_puts $timing_log "  WHS (Worst Hold Slack)     : ${whs} ns"
    log_puts $timing_log "  THS (Total Hold Slack)     : ${ths} ns"

    # Timing status verdict
    log_puts $timing_log ""
    if {[string is double -strict $wns] && $wns < 0} {
        log_puts $timing_log "  STATUS : *** TIMING FAILED *** (WNS = ${wns} ns)"
    } elseif {[string is double -strict $wns] && $wns >= 0} {
        log_puts $timing_log "  STATUS : TIMING MET (WNS = ${wns} ns)"
    } else {
        log_puts $timing_log "  STATUS : Could not determine"
    }

    log_puts $timing_log ""
    log_puts $timing_log "=== Clock Domains ==="
    foreach clk $clocks {
        log_puts $timing_log [format "  %-20s  Period: %6s ns   Freq: %7s MHz" \
            [lindex $clk 0] [lindex $clk 1] [lindex $clk 2]]
    }

    log_puts $timing_log ""
    log_puts $timing_log "=== Per-Clock Violations ==="
    foreach v $violations {
        set clk_n  [lindex $v 0]
        set v_wns  [lindex $v 1]
        set v_tns  [lindex $v 2]
        set v_fail [lindex $v 3]
        if {[string is double -strict $v_wns] && $v_wns < 0} {
            log_puts $timing_log [format "  \[FAIL\] %-16s WNS=%6s ns  TNS=%8s ns  Failing=%s" \
                $clk_n $v_wns $v_tns $v_fail]
        } else {
            log_puts $timing_log [format "  \[ OK \] %-16s WNS=%6s ns  TNS=%8s ns  Failing=%s" \
                $clk_n $v_wns $v_tns $v_fail]
        }
    }

    divider $timing_log

    # Pass back key values for summary
    return [list $wns $tns $tns_failing $whs]
}

# ============================================================
# UTILIZATION PARSER
# ============================================================
proc parse_utilization {filename util_log summary_log} {

    log_puts $util_log "UTILIZATION REPORT"
    log_puts $util_log "Parsed from: $filename"
    divider $util_log

    set fd [open $filename r]

    # Resource containers
    array set resources {}

    # Targets to extract: {label regex_pattern}
    set targets {
        {"Slice LUTs"       {Slice LUTs\s+\|\s+(\d+)\s+\|[^|]+\|[^|]+\|\s+(\d+)\s+\|\s+([\d.]+)}}
        {"LUT as Logic"     {LUT as Logic\s+\|\s+(\d+)\s+\|[^|]+\|[^|]+\|\s+(\d+)\s+\|\s+([\d.]+)}}
        {"LUT as Memory"    {LUT as Memory\s+\|\s+(\d+)\s+\|[^|]+\|[^|]+\|\s+(\d+)\s+\|\s+([\d.]+)}}
        {"Slice Registers"  {Slice Registers\s+\|\s+(\d+)\s+\|[^|]+\|[^|]+\|\s+(\d+)\s+\|\s+([\d.]+)}}
        {"Block RAM Tile"   {Block RAM Tile\s+\|\s+(\d+)\s+\|[^|]+\|[^|]+\|\s+(\d+)\s+\|\s+([\d.]+)}}
        {"DSPs"             {DSPs\s+\|\s+(\d+)\s+\|[^|]+\|[^|]+\|\s+(\d+)\s+\|\s+([\d.]+)}}
        {"Bonded IOB"       {Bonded IOB\s+\|\s+(\d+)\s+\|[^|]+\|[^|]+\|\s+(\d+)\s+\|\s+([\d.]+)}}
        {"BUFGCTRL"         {BUFGCTRL\s+\|\s+(\d+)\s+\|[^|]+\|[^|]+\|\s+(\d+)\s+\|\s+([\d.]+)}}
        {"MMCME2_ADV"       {MMCME2_ADV\s+\|\s+(\d+)\s+\|[^|]+\|[^|]+\|\s+(\d+)\s+\|\s+([\d.]+)}}
    }

    while {[gets $fd line] >= 0} {
        foreach target $targets {
            set label   [lindex $target 0]
            set pattern [lindex $target 1]
            if {[regexp $pattern $line -> used avail util_pct]} {
                set resources($label) [list $used $avail $util_pct]
            }
        }
    }

    close $fd

    # ----------------------------------------
    # Write utilization log
    # ----------------------------------------
    log_puts $util_log ""
    log_puts $util_log [format "  %-20s  %8s / %-8s  %7s" \
        "Resource" "Used" "Avail" "Util%"]
    log_puts $util_log [format "  %-20s  %8s   %-8s  %7s" \
        "--------" "----" "-----" "-----"]

    # Thresholds for warnings
    set warn_pct  70.0
    set crit_pct  90.0

    set resource_order {
        "Slice LUTs"
        "LUT as Logic"
        "LUT as Memory"
        "Slice Registers"
        "Block RAM Tile"
        "DSPs"
        "Bonded IOB"
        "BUFGCTRL"
        "MMCME2_ADV"
    }

    foreach res $resource_order {
        if {[info exists resources($res)]} {
            set used  [lindex $resources($res) 0]
            set avail [lindex $resources($res) 1]
            set pct   [lindex $resources($res) 2]

            # Status tag
            if {[string is double -strict $pct] && $pct >= $crit_pct} {
                set tag "!!! CRITICAL"
            } elseif {[string is double -strict $pct] && $pct >= $warn_pct} {
                set tag "!   WARNING "
            } else {
                set tag "    OK     "
            }

            log_puts $util_log [format "  \[%s\] %-20s  %8s / %-8s  %6s%%" \
                $tag $res $used $avail $pct]
        }
    }

    divider $util_log
    return [array get resources]
}

# ============================================================
# MAIN — Run parsers and write summary
# ============================================================

puts "\n============================================================"
puts " Vivado Report Parser — ayengec"
puts "============================================================\n"

# --- Parse timing ---
puts "INFO: Parsing timing report..."
set timing_results [parse_timing $timing_rpt $timing_log $summary_log]
set t_wns  [lindex $timing_results 0]
set t_tns  [lindex $timing_results 1]
set t_fail [lindex $timing_results 2]

# --- Parse utilization ---
puts "\nINFO: Parsing utilization report...\n"
set util_results [parse_utilization $util_rpt $util_log $summary_log]
array set util_data $util_results

# ============================================================
# FINAL SUMMARY
# ============================================================
divider $summary_log
log_puts $summary_log "  REPORT PARSER SUMMARY"
divider $summary_log
log_puts $summary_log ""

# Timing verdict
if {[string is double -strict $t_wns] && $t_wns < 0} {
    log_puts $summary_log "  TIMING   : *** FAILED ***  WNS=$t_wns ns | TNS=$t_tns ns | Failing Endpoints=$t_fail"
} else {
    log_puts $summary_log "  TIMING   : PASSED          WNS=$t_wns ns"
}

# Key utilization summary
foreach res {"Slice LUTs" "Slice Registers" "Block RAM Tile" "DSPs"} {
    if {[info exists util_data($res)]} {
        set used [lindex $util_data($res) 0]
        set avail [lindex $util_data($res) 1]
        set pct  [lindex $util_data($res) 2]
        log_puts $summary_log [format "  %-16s : %5s / %-5s (%s%%)" $res $used $avail $pct]
    }
}

log_puts $summary_log ""
log_puts $summary_log "  Logs written to: $log_dir/"
divider $summary_log

close $summary_log
close $timing_log
close $util_log

puts "\nINFO: All done. Check $log_dir/ for full reports."
