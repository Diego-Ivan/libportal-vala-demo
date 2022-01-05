/* Background.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    public class Pages.Background : Page {
        private Gtk.Entry reason_entry;
        private Gtk.Switch autostart_switch;
        private Gtk.Button request_button;
        public Background (Xdp.Portal portal_, Gtk.Window parent_win) {
            Object (
                portal: portal_,
                parent_window: parent_win,
                title: "Background"
            );
        }

        construct {
            title = "Background";
            build_ui ();

            var status = child as Adw.StatusPage;
            status.bind_property ("title",
                this, "title",
                SYNC_CREATE | BIDIRECTIONAL
            );

            request_button.clicked.connect (request_button_clicked);
        }

        public void request_button_clicked () {
            if (reason_entry.text == "") {
                reason_entry.add_css_class ("error");
                return;
            }
            else {
                reason_entry.remove_css_class ("error");
            }

            Xdp.BackgroundFlags flags;

            if (autostart_switch.active) {
                flags = AUTOSTART;
            }
            else {
                flags = NONE;
            }

            Xdp.Parent parent = Xdp.parent_new_gtk (parent_window);

            GLib.GenericArray<weak string> array = new GLib.GenericArray<weak string>();
            array.add ("/bin/true");

            portal.request_background.begin (
                parent,
                reason_entry.text,
                array,
                flags,
                null,
                ((obj, res) => {
                    try {
                        bool? success;
                        success = portal.request_background.end (res);

                        if (success == null) {
                            critical ("Background portal cancelled");
                            return;
                        }
                    }
                    catch (Error e) {
                        critical (e.message);
                    }
                })
            );
        }

        public override void build_ui () {
            try {
                var builder = new Gtk.Builder ();
                builder.add_from_resource ("/io/github/diegoivanme/libportal_vala_sample/Background.ui");
                child = builder.get_object ("main_widget") as Gtk.Widget;

                reason_entry = builder.get_object ("reason_entry") as Gtk.Entry;
                autostart_switch = builder.get_object ("autostart_switch") as Gtk.Switch;
                request_button = builder.get_object ("request_button") as Gtk.Button;
            }
            catch (Error e) {
                critical ("Error loading UI file: %s", e.message);
            }
        }
    }
}
