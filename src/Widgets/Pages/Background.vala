/* Background.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    // https://valadoc.org/libportal/Xdp.Portal.request_background.html
    [GtkTemplate (ui = "/io/github/diegoivanme/libportal_vala_sample/Background.ui")]
    public class Pages.Background : Page {
        [GtkChild]
        private unowned Adw.EntryRow reason_entry;
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

            // https://valadoc.org/libportal/Xdp.Parent.html
            Xdp.Parent parent = Xdp.parent_new_gtk ((Gtk.Window) get_native ());

            GLib.GenericArray<weak string> array = new GLib.GenericArray<weak string>();
            array.add ("/bin/true"); // /bin/true will be autostarted

            portal.request_background.begin (
                parent, // Xdp.Parent
                reason_entry.text, // Reason to ask for running in the background. Displayed to the user
                array, // Commands that will autostart
                autostart_switch.active ? Xdp.BackgroundFlags.AUTOSTART : Xdp.BackgroundFlags.NONE, // Flags for the portal. Whether the application will autostart too or will be just running in the background
                null, // Cancellable. We are using none
                callback // Callback of the portal, in which we will receive the results of the petition
            );
        }

        public override void callback (GLib.Object? obj, GLib.AsyncResult res) {
            try {
                bool? success;
                result_label.visible = true;
                success = portal.request_background.end (res); // Receive if the request was successful or not

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
                critical (e.message); // Handle error
                result_label.label = e.message;
                result_label.add_css_class ("error");
            }
        }
    }
}
