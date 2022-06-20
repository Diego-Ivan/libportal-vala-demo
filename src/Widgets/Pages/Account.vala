/* Account.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    // https://valadoc.org/libportal/Xdp.Portal.get_user_information.html
    [GtkTemplate (ui = "/io/github/diegoivanme/libportal_vala_sample/Accounts.ui")]
    public class Pages.Account : Page {
        [GtkChild]
        private unowned Gtk.Image avatar;
        [GtkChild]
        private unowned Adw.EntryRow reason_entry;
        [GtkChild]
        private unowned Gtk.Button request_button;
        [GtkChild]
        private unowned Gtk.Label name_label;
        [GtkChild]
        private unowned Gtk.Label id_label;
        [GtkChild]
        private unowned Gtk.Box results_box;
        private bool request_succesful { get; set; }

        public Account (Xdp.Portal portal_) {
            Object (
                portal: portal_
            );
        }

        construct {
            request_button.clicked.connect (() => {

                if (reason_entry.text == "") {
                    reason_entry.add_css_class ("error");
                    return;
                }
                else {
                    reason_entry.remove_css_class ("error");
                }

                // https://valadoc.org/libportal/Xdp.Parent.html
                var parent = Xdp.parent_new_gtk (get_native () as Gtk.Window);

                portal.get_user_information.begin (
                    parent, // Xdp.Parent
                    reason_entry.text, // Reason to provide the information, it will be displayed to the user
                    NONE, // Flags to ask for the user information. Currently, NONE is the only value
                    null, // A cancellable. We are not using any.
                    callback // Function callback, in this one, we will receive the information
                );
            });
        }

        public override void callback (GLib.Object? obj, GLib.AsyncResult res) {
            GLib.Variant info;
            try {
                info = portal.get_user_information.end (res); // The return value is a GLib.Variant
                if (info == null) { // Checking for null
                    critical ("Account Portal Cancelled");
                    return;
                }

               Variant name = info.lookup_value ("name", VariantType.STRING); // Looking for the username
               Variant id = info.lookup_value ("id", VariantType.STRING); // Looking for the user ID
               Variant uri = info.lookup_value ("image", VariantType.STRING); // Looking for the profile picture, available as a file URI

               name_label.label = (string) name; // Cast name as string to set it to the label
               id_label.label = (string) id; // Cast ID as string to set it to the label
               string path = (string) uri; // Cast the URI as string to load it

               if (path != "") {
                    var file = GLib.Filename.from_uri (path);
                    var pixbuf = new Gdk.Pixbuf.from_file_at_size (
                        file,
                        120,
                        120
                    );
                    avatar.set_from_pixbuf (pixbuf); // Displaying the received image
               }

               results_box.visible = true;
            }
            catch (Error e){
                results_box.visible = false;
                critical (e.message); // Show the error message
            }
        }
    }
}
