/* Welcome.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    public class Pages.Welcome : Page {
        private Gtk.Label status_label;

        public Welcome (Xdp.Portal portal_, Gtk.Window parent_win) {
            Object (
                portal: portal_,
                parent_window: parent_win,
                title: "Welcome"
            );
        }

        construct {
            title = "Welcome";
            build_ui ();

            var status = child as Adw.StatusPage;

            var path = GLib.Path.build_filename (
                GLib.Environment.get_user_runtime_dir (),
                "flatpak-info"
            );

            bool sandboxed = GLib.FileUtils.test (path, EXISTS);

            if (sandboxed) {
                status.icon_name = "security-high-symbolic";
                status_label.label = "Confined";
                status_label.add_css_class ("success");
            }
            else {
                status.icon_name = "security-high-symbolic";
                status_label.label = "Unconfined";
                status_label.add_css_class ("warning");
            }
        }

        public override void build_ui () {
            try {
                var builder = new Gtk.Builder ();
                builder.add_from_resource ("/io/github/diegoivanme/libportal_vala_sample/Welcome.ui");
                child = builder.get_object ("main_widget") as Gtk.Widget;

                status_label = builder.get_object ("status_label") as Gtk.Label;
            }
            catch (Error e) {
                critical ("Error loading UI file: %s", e.message);
            }
        }
    }
}
