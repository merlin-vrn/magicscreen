#!/usr/bin/env tclsh

package require Tk

set myWidth 400
set myHeight 300

set img [image create photo -width $myWidth -height $myHeight]
ttk::scrollbar .vsb -orient vertical -command {.cnv yview}
ttk::scrollbar .hsb -orient horizontal -command {.cnv xview}
canvas .cnv -width $myWidth -height $myHeight -scrollregion [list 0 0 $myWidth $myHeight] -xscrollcommand {.hsb set} -yscrollcommand {.vsb set}

.cnv create image 0 0 -image $img -anchor nw

ttk::label .clr -background #000
set clr #000
proc setclr {newclr} {
    global clr
    .clr configure -background $newclr
    set clr $newclr
}

grid .cnv .vsb -sticky nsew
grid .hsb .clr -sticky nsew
grid [ttk::frame .sub] -sticky nsew -columnspan 2

grid columnconfigure . 0 -weight 1
grid rowconfigure . 0 -weight 1

set coox 0
set cooy 0
grid [ttk::label .sub.lblx -text "x:"] [ttk::label .sub.coox -textvariable coox] \
     [ttk::label .sub.lbly -text "y:"] [ttk::label .sub.cooy -textvariable cooy] -sticky nsew

for {set c 0} {$c<8} {incr c} {
    set clr #[expr {(($c&1)?"f":"0")}][expr {(($c&2)?"f":"0")}][expr {(($c&4)?"f":"0")}]
    ttk::label .sub.clr$c -width 2 -text " " -background $clr
    grid .sub.clr$c -column [expr {$c+4}] -row 0 -sticky nsew
    bind .sub.clr$c <ButtonPress-1> [list setclr $clr]
}

# canvas image data visibility test - BEGIN
for {set i 1} {$i<$myWidth-1} {incr i} {
    $img put #0f0 -to $i 0
    $img put #ff0 -to $i [expr $myHeight-1]
}
    for {set j 1} {$j<$myHeight-1} {incr j} {
    $img put #f00 -to 0 $j
    $img put #00f -to [expr $myWidth-1] $j
}
$img put #000 -to 0 0
$img put #000 -to 1 1
$img put #000 -to [expr $myWidth-1] [expr $myHeight-1]
$img put #000 -to [expr $myWidth-2] [expr $myHeight-2]
$img put #000 -to 0 [expr $myHeight-1]
$img put #000 -to 1 [expr $myHeight-2]
$img put #000 -to [expr $myWidth-1] 0
$img put #000 -to [expr $myWidth-2] 1
# canvas image data visibility test - END

proc coo_screen_to_canvas {x y} {
    set scrollregion [.cnv cget -scrollregion]
    set xview [.cnv xview]
    set yview [.cnv yview]
    set coox [expr {int([lindex $xview 0]*[lindex $scrollregion 2]+$x-2)}]
    set cooy [expr {int([lindex $yview 0]*[lindex $scrollregion 3]+$y-2)}]
    return [list $coox $cooy]
}

proc displaycoo {x y} {
    global coox cooy
    lassign [coo_screen_to_canvas $x $y] coox cooy
}
bind .cnv <Motion> {displaycoo %x %y}
set btn1 0
bind .cnv <ButtonPress-1> {set btn1 1}
bind .cnv <ButtonRelease-1> {set btn1 0}

proc putpoint {} {
    global img btn1 coox cooy clr
    if {$btn1} {
        $img put $clr -to $coox $cooy
    }
}
bind .cnv <Motion> +{putpoint}
