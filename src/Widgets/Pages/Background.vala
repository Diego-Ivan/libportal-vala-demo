/* Background.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    [GtkTemplate (ui = "/io/github/diegoivanme/libportal_vala_sample/Background.ui")]
    public class Pages.Background : Page {
        [GtkChild]
        private unowned Gtk.Entry reason_entry;
        [GtkChild]
        private unowned Gtk.Switch autostart_switch;
        [GtkChild]
        private unowned Gtk.Label result_label;

        public Background (Xdp.Portal portal_) {
            Object (
                portal: portal_
            );
        }

        [GtkCallback]
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

            Xdp.Parent parent = Xdp.parent_new_gtk (get_native () as Gtk.Window);

            GLib.GenericArray<weak string> array = new GLib.GenericArray<weak string>();
            array.add ("/bin/true");

            portal.request_background.begin (
                parent,
                reason_entry.text,
                array,
                flags,
                null,
                callback
            );
        }

        public override void callback (GLib.Object? obj, GLib.AsyncResult res) {
            try {
                bool? success;
                result_label.visible = true;
                success = portal.request_background.end (res);

                if (success) {
                    result_label.label = "Request successful";
                    result_label.add_css_class ("success");
                }
                else {
                    result_label.label = "Request failed";
                    result_label.add_css_class ("warning");
                }

                if (success == null) {
                    critical ("Background portal cancelled");
                    result_label.label = "Background portal cancelled";
                    result_label.add_css_class ("warning");
                    return;
                }
            }
            catch (Error e) {
                critical (e.message);
                result_label.label = e.message;
                result_label.add_css_class ("error");
            }
        }
    }
}
