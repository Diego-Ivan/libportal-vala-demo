/* Screenshot.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    [GtkTemplate (ui = "/io/github/diegoivanme/libportal_vala_sample/Screenshot.ui")]
    public class Pages.Screenshot : Page {
        [GtkChild]
        private unowned Gtk.Switch interactive_switch;
        [GtkChild]
        private unowned Gtk.Label result_label;
        [GtkChild]
        private unowned Gtk.Image screenshot;
        [GtkChild]
        private unowned Adw.PreferencesGroup results_group;

        public Screenshot (Xdp.Portal portal_) {
            Object (
                portal: portal_
            );
        }

        [GtkCallback]
        private void on_capture_button_clicked () {
            bool interactive = interactive_switch.active;
            Xdp.Parent parent = Xdp.parent_new_gtk (get_native () as Gtk.Window);

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
    }
}
