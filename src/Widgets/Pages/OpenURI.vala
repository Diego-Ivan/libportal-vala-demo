/* OpenURI.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    [GtkTemplate (ui = "/io/github/diegoivanme/libportal_vala_sample/OpenURI.ui")]
    public class Pages.OpenURI : Page {
        [GtkChild]
        private unowned Gtk.Entry uri_entry;
        [GtkChild]
        private unowned Gtk.Switch ask_switch;
        [GtkChild]
        private unowned Gtk.Switch writable_switch;

        public OpenURI (Xdp.Portal portal_) {
            Object (
                portal: portal_
            );
        }

        [GtkCallback]
        private void on_open_button_clicked () {
            Xdp.OpenUriFlags flags = NONE;
            Xdp.Parent parent = Xdp.parent_new_gtk (get_native () as Gtk.Window);

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
    }
}
