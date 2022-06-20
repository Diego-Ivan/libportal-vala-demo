/* OpenURI.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    // https://valadoc.org/libportal/Xdp.Portal.open_uri.html
    [GtkTemplate (ui = "/io/github/diegoivanme/libportal_vala_sample/OpenURI.ui")]
    public class Pages.OpenURI : Page {
        [GtkChild]
        private unowned Adw.EntryRow uri_entry;
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
            // https://valadoc.org/libportal/Xdp.Parent.html
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
                parent, // Xdp.Parent
                uri_entry.text, // URI that will be open by the portal
                flags, // Flags of the request, whether it should ASK preferred browser, whether the file is WRITABLE, both or NONE
                null, // Cancellable, we're using NONE
                callback // Callback in which we will receive the result of our petition
            );
        }

        public override void callback (GLib.Object? obj, GLib.AsyncResult res) {
            bool result;
            uri_entry.remove_css_class ("error");

            try {
                result = portal.open_uri.end (res); // Boolean that indicates if the request was successful

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
