/* Screenshot.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    public class Pages.Screenshot : Page {
        private Gtk.Switch interactive_switch;
        private Gtk.Label result_label;
        private Gtk.Image screenshot;
        private Gtk.Button capture_button;
        private Adw.PreferencesGroup results_group;

        public Screenshot (Xdp.Portal portal_, Gtk.Window parent_win) {
            Object (
                portal: portal_,
                parent_window: parent_win,
                title: "Screenshot"
            );
        }

        construct {
            build_ui ();

            var status = child as Adw.StatusPage;
            status.bind_property ("title",
                this, "title",
                SYNC_CREATE | BIDIRECTIONAL
            );

            capture_button.clicked.connect (on_capture_button_clicked);
        }

        private void on_capture_button_clicked () {
            bool interactive = interactive_switch.active;
            Xdp.Parent parent = Xdp.parent_new_gtk (parent_window);

            portal.take_screenshot.begin (
                parent,
                interactive ? Xdp.ScreenshotFlags.INTERACTIVE : Xdp.ScreenshotFlags.NONE,
                null,
                callback
            );
        }

        public override void callback (GLib.Object? obj, GLib.AsyncResult res) {
            string uri;
            results_group.visible = true;
            result_label.remove_css_class ("error");

            try {
                uri = portal.take_screenshot.end (res);
                string path = GLib.Filename.from_uri (uri, null);

                var pixbuf = new Gdk.Pixbuf.from_file_at_scale (
                    path,
                    120,
                    80,
                    true
                );

                result_label.label = path;
                screenshot.set_from_pixbuf (pixbuf);
            }
            catch (Error e) {
                critical (e.message);
                result_label.label = e.message;
                result_label.add_css_class ("error");
            }
        }

        public override void build_ui () {
            try {
                var builder = new Gtk.Builder ();
                builder.add_from_resource ("/io/github/diegoivanme/libportal_vala_sample/Screenshot.ui");
                child = builder.get_object ("main_widget") as Gtk.Widget;

                interactive_switch = builder.get_object ("interactive_switch") as Gtk.Switch;
                result_label = builder.get_object ("result_label") as Gtk.Label;
                screenshot = builder.get_object ("screenshot") as Gtk.Image;
                results_group = builder.get_object ("results_group") as Adw.PreferencesGroup;
                capture_button = builder.get_object ("capture_button") as Gtk.Button;
            }
            catch (Error e) {
                critical ("Error loading UI file: %s", e.message);
            }
        }
    }
}
