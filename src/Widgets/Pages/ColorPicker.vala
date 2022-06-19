/* ColorPicker.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
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
            Xdp.Parent parent = Xdp.parent_new_gtk (get_native () as Gtk.Window);
            portal.pick_color.begin (
                parent,
                null,
                callback
            );
        }

        public override void callback (GLib.Object? obj, GLib.AsyncResult res) {
            GLib.Variant colors;

            try {
                colors = portal.pick_color.end (res);
                double red = 0;
                double green = 0;
                double blue = 0;

                GLib.VariantIter iter = colors.iterator ();
                iter.next ("d", &red);
                iter.next ("d", &green);
                iter.next ("d", &blue);

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
