//switch measurements
// can be used for top plate
switch_middle_width = 14;
switch_rim_width = 15.66;
// from rim to bottom flat part, contacts stick out
switch_bottom_height = 5;
// height of the stuff sticking out the bottom ofthe switches
switch_stickout_height = 3.2;
// approximated, to enable soldering
switch_clearance = switch_bottom_height + switch_stickout_height + 3;

// arduino measurements
arduino_width = 18.2;
// without usb
arduino_length = 33.5;
port_depth = 1.4; // overhang of the port
port_length = 5.8;
port_width = 7.75;
port_height = 2.6;
port_clearance = 0.2;
arduino_hole_diameter = 1.65;
arduino_hole_r = arduino_hole_diameter/2;
arduino_hole_inset = 0.46;
arduino_board_thickness =1.5+1.5; // calculate standoffs of solderoed on parts into thickness

// u=19.5
switch_padding = 19.5;

module enclosure_top(switch_count, width, length, height,  wall_thickness=2, preview_keys=false, preview_arduino=false) {
    switch_inset_w = (width-switch_middle_width)/2;
    switch_inset_l = (length-switch_padding*switch_count)/2;
    arduino_clearance = (width-arduino_width)/2-wall_thickness;
    arduino_elevation = wall_thickness;
    translate([-width/2, -length/2, 0]) {
        union() {
            difference () {
                enclosure_top_base(width, length, height, wall_thickness);
                    // switch holes
                    for (i = [0:switch_count-1]) {
                        translate([switch_inset_w, switch_inset_l + (switch_padding-switch_middle_width)/2 + (switch_padding*i), height-wall_thickness-0.1]) cube(size=[switch_middle_width, switch_middle_width, wall_thickness+0.2]);
                    }
                    // port hole
                    translate([width/2-port_width/2-port_clearance, -0.1, -port_clearance-0.1]) cube(size=[port_width+port_clearance*2, wall_thickness+0.2, port_height + arduino_board_thickness + port_clearance*2 + 0.1 + arduino_elevation]);
            }
            // arduino back support
            buffer = 0.2; // don't fit it too tight!
            translate([0, arduino_length+buffer+wall_thickness, arduino_elevation]) cube(size=[width, wall_thickness, wall_thickness + arduino_board_thickness]);
            translate([width/2-arduino_width/4, arduino_length, arduino_elevation+arduino_board_thickness + buffer ]) cube(size=[arduino_width/2, wall_thickness+buffer, wall_thickness-buffer]);
            // bottom support
            translate([0, length-wall_thickness*2, wall_thickness + buffer]) cube(size=[width, wall_thickness*2, wall_thickness]);
        }
        if (preview_keys) {
            base_offset = (length - switch_count*switch_padding)/2;
            for (i = [0:switch_count-1]) {
                translate([width/2, base_offset-switch_padding/2+switch_padding+i*switch_padding, height]) render_key();
            }
        }
        if (preview_arduino) {
            translate([width/2, arduino_length/2+wall_thickness, arduino_elevation]) render_arduino();
        }
    }
}

module enclosure_bottom(width, length, wall_thickness=2,use_teeth=false) {
//    clip_width = width-2*wall_thickness;
//    clip_height = 1.5*wall_thickness;
    translate([-width/2, -length/2, 0]) {
        union() {
            // base plate
            translate([wall_thickness, wall_thickness, 0]) cube(size=[width-2*wall_thickness, length-2*wall_thickness, wall_thickness]);
            // port hole bottom
            translate([width/2-port_width/2-port_clearance, 0, 0]) cube(size=[port_width+port_clearance*2, wall_thickness, arduino_board_thickness -port_clearance + wall_thickness]);
//            // back clip
//            translate([width/2-clip_width/2, length-wall_thickness*2, 0]) cube(size=[clip_width, wall_thickness, clip_height]);
//            if(use_teeth) {
//                clip_tooth_diameter = wall_thickness*2/3;
//                clip_tooth_depth = wall_thickness*2/3;
//                num_clip_teeth = 3;
//                for (i = [0:num_clip_teeth-1]) {
//                    offset = ((clip_width-clip_tooth_diameter) / (num_clip_teeth-1)) * i;
//                    translate([width/2-clip_width/2+offset, length-wall_thickness*2, clip_height-clip_tooth_diameter]) cube(size=[clip_tooth_diameter, wall_thickness+clip_tooth_depth, clip_tooth_diameter]);
//                }
//            }
        }
    }
}


module enclosure_top_base(width, length, height, wall_thickness) {
    difference() {
        cube_with_shaved_off_edges(width, length, height, wall_thickness);
        translate([wall_thickness, wall_thickness, -.1]) cube_with_shaved_off_edges(width-2*wall_thickness, length-2*wall_thickness, height-wall_thickness+0.1, wall_thickness);
    }
}

module cube_with_shaved_off_edges(width, length, height, shave_off_amount) {
    difference() {
        cube(size=[width, length, height]);
        translate([0, -0.1, height-shave_off_amount]) rotate([0,-45,0]) cube(size=[width, length+0.2, shave_off_amount]);
        translate([width, 0.1+length, height-shave_off_amount]) rotate([0,-45, 180]) cube(size=[width, length+0.2, shave_off_amount]);
        translate([-0.1, length-shave_off_amount, height]) rotate([-45,0,0]) cube(size=[width+0.2, length, shave_off_amount]);
        translate([width+0.1, shave_off_amount, height]) rotate([-45,0,180]) cube(size=[width+0.2, length, shave_off_amount]);
    }
}

module mounting_foot(base_width, base_length, base_thickness, front=false, mirrored=false, reduce=0.2, $fn=360) {
    // arduino mounting feet
    tr_front_back = front ? arduino_length-arduino_hole_r-arduino_hole_inset : arduino_hole_inset+arduino_hole_r;
    tr_mirrored = mirrored ? arduino_width-arduino_hole_inset-arduino_hole_r : arduino_hole_inset+arduino_hole_r;
    translate([tr_mirrored, tr_front_back,0])
    union() {
        cylinder(r2=arduino_hole_r, r1=arduino_hole_r-reduce, h=arduino_board_thickness/5, $fn=$fn);
        translate([0,0, arduino_board_thickness/5])
        cylinder(r=arduino_hole_r, h=arduino_board_thickness/5*4, $fn=$fn);
        // base
        tr = mirrored ? [-arduino_hole_r, -base_length/2, arduino_board_thickness] : [arduino_hole_r-base_width, -base_length/2, arduino_board_thickness];
        translate(tr) cube(size=[base_width, base_length, base_thickness]);
    }
}

module render_arduino() {
    color([1,0,0, 0.5])
    translate([-arduino_width/2,-arduino_length/2,0]) union() {
            cube(size=[arduino_width, arduino_length, arduino_board_thickness]);
        
        // add the port
        translate([(arduino_width/2)-port_width/2, -port_depth, arduino_board_thickness]) cube(size=[port_width, port_length, port_height]);
    }
}

module render_key() {
    small_stickout_r=1.66/2;
    big_stickout_r=1.7;
    rim_inset = (switch_rim_width-switch_middle_width)/2;
    color([0,1,1, 0.2])
    translate([-switch_rim_width/2,-switch_rim_width/2,0])
    union() {
        cube(size=[switch_rim_width, switch_rim_width, 1]);
        translate([rim_inset, rim_inset, -switch_bottom_height]) cube(size=[switch_middle_width, switch_middle_width, switch_bottom_height]);
        translate([rim_inset, rim_inset, 1]) cube(size=[switch_middle_width, switch_middle_width, switch_bottom_height]);
        translate([switch_rim_width/2, switch_rim_width/2, -switch_bottom_height-switch_stickout_height]) cylinder(r=big_stickout_r, h=switch_stickout_height, $fn=360);
    }
}

// comment these commands or change true -> false to turn off rendering for components
enclosure_top(3, switch_padding+4, 3* switch_padding+4, switch_clearance + 7, 2, true, true);
color([0,0,1]) enclosure_bottom(switch_padding+4, 3*switch_padding+4, 2);
