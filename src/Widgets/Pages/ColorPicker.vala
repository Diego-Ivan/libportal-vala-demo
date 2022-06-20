/* ColorPicker.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    // https://valadoc.org/libportal/Xdp.Portal.pick_color.html
    [GtkTemplate (ui = "/io/github/diegoivanme/libportal_vala_sample/ColorPicker.ui")]
    public class Pages.ColorPicker : Page {
        [GtkChild]
        private unowned ColorViewer color_viewer;
        [GtkChild]
        private unowned Gtk.Label red_label;
        [GtkChild]
        private unowned Gtk.Label green_label;
        [GtkChild]
        private unowned Gtk.Label blue_label;

        public ColorPicker (Xdp.Portal portal_) {
            Object (
                portal: portal_
            );
        }

        static construct {
            typeof (ColorViewer).ensure ();
        }

        [GtkCallback]
        private void on_pick_button_clicked () {
            // https://valadoc.org/libportal/Xdp.Parent.html
            Xdp.Parent parent = Xdp.parent_new_gtk (get_native () as Gtk.Window);
            portal.pick_color.begin (
                parent, // Xdp.Parent
                null, // Cancellable, we're using none
                callback // Callback for the function in which we will receive the result of our petition
            );
        }

        public override void callback (GLib.Object? obj, GLib.AsyncResult res) {
            GLib.Variant colors;

            try {
                colors = portal.pick_color.end (res); // Obtain the Variant with the RGB colors
                double red = 0;
                double green = 0;
                double blue = 0;

                GLib.VariantIter iter = colors.iterator (); // Iterate over the Variant
                iter.next ("d", &red); // Obtain red
                iter.next ("d", &green); // Obtain green
                iter.next ("d", &blue); // Obtain Blue

                // Display the colors obtain in screen.
                color_viewer.color = {
                    (float) red,
                    (float) green,
                    (float) blue,
                    1
                };

                red_label.label = parse_color (red);
                green_label.label = parse_color (green);
                blue_label.label = parse_color (blue);
            }
            catch (Error e) {
                critical (e.message);
            }
        }

        private string parse_color (double color) {
            uint code = (uint) (color * 256);

            return code.to_string ();
        }
    }
}
