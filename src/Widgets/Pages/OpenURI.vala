/* OpenURI.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    public class Pages.OpenURI : Page {
        private Gtk.Entry uri_entry;
        private Gtk.Switch ask_switch;
        private Gtk.Switch writable_switch;
        private Gtk.Button open_button;

        public OpenURI (Xdp.Portal portal_, Gtk.Window parent_win) {
            Object (
                portal: portal_,
                parent_window: parent_win,
                title: "Open URI"
            );
        }

        construct {
            build_ui ();
            var status = child as Adw.StatusPage;
            status.bind_property ("title",
                this, "title",
                SYNC_CREATE | BIDIRECTIONAL
            );

            open_button.clicked.connect (on_open_button_clicked);
        }

        private void on_open_button_clicked () {
            Xdp.OpenUriFlags flags = NONE;
            Xdp.Parent parent = Xdp.parent_new_gtk (parent_window);

            if (ask_switch.active && writable_switch.active) {
                flags = ASK | WRITABLE;
            }
            else if (ask_switch.active) {
                flags = ASK;
            }
            else if (writable_switch.active) {
                flags = WRITABLE;
            }

            portal.open_uri.begin (
                parent,
                uri_entry.text,
                flags,
                null,
                callback
            );
        }

        public override void callback (GLib.Object? obj, GLib.AsyncResult res) {
            bool result;
            uri_entry.remove_css_class ("error");

            try {
                result = portal.open_uri.end (res);

                if (!result) {
                    uri_entry.add_css_class ("error");
                }
            }
            catch (Error e) {
                uri_entry.add_css_class ("error");
                critical (e.message);
            }
        }

        public override void build_ui () {
            try {
                var builder = new Gtk.Builder ();
                builder.add_from_resource ("/io/github/diegoivanme/libportal_vala_sample/OpenURI.ui");
                child = builder.get_object ("main_widget") as Gtk.Widget;

                uri_entry = builder.get_object ("uri_entry") as Gtk.Entry;
                ask_switch = builder.get_object ("ask_switch") as Gtk.Switch;
                writable_switch = builder.get_object ("writable_switch") as Gtk.Switch;
                open_button = builder.get_object ("open_button") as Gtk.Button;
            }
            catch (Error e) {
                critical ("Error loading UI file: %s", e.message);
            }
        }
    }
}
