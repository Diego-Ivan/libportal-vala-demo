/* ColorPicker.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    public class Pages.ColorPicker : Page {
        private Gtk.Box result_box;
        private Gtk.Button pick_button;
        private ColorViewer color_viewer;
        private Gtk.Label red_label;
        private Gtk.Label green_label;
        private Gtk.Label blue_label;

        public ColorPicker (Xdp.Portal portal_, Gtk.Window parent_win) {
            Object (
                portal: portal_,
                parent_window: parent_win,
                title: "Color Picker"
            );
        }

        construct {
            build_ui ();
            var status = child as Adw.StatusPage;
            status.bind_property ("title",
                this, "title",
                SYNC_CREATE | BIDIRECTIONAL
            );
            pick_button.clicked.connect (on_pick_button_clicked);
        }

        private void on_pick_button_clicked () {
            Xdp.Parent parent = Xdp.parent_new_gtk (parent_window);
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

        public override void build_ui () {
            try {
                var builder = new Gtk.Builder ();
                builder.add_from_resource ("/io/github/diegoivanme/libportal_vala_sample/ColorPicker.ui");
                child = builder.get_object ("main_widget") as Gtk.Widget;

                result_box = builder.get_object ("result_box") as Gtk.Box;
                pick_button = builder.get_object ("pick_button") as Gtk.Button;
                red_label = builder.get_object ("red_label") as Gtk.Label;
                green_label = builder.get_object ("green_label") as Gtk.Label;
                blue_label = builder.get_object ("blue_label") as Gtk.Label;

                color_viewer = new ColorViewer () {
                    valign = CENTER
                };
                result_box.prepend (color_viewer);
            }
            catch (Error e) {
                critical ("Error loading UI file: %s", e.message);
            }
        }

    }
}
