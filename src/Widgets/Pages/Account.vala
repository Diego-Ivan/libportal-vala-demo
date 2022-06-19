/* Account.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    [GtkTemplate (ui = "/io/github/diegoivanme/libportal_vala_sample/Accounts.ui")]
    public class Pages.Account : Page {
        [GtkChild]
        private unowned Gtk.Image avatar;
        [GtkChild]
        private unowned Gtk.Entry reason_entry;
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
                portal: portal_,
                title: "Accounts"
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

                var parent = Xdp.parent_new_gtk (get_native () as Gtk.Window);

                portal.get_user_information.begin (
                    parent,
                    reason_entry.text,
                    NONE,
                    null,
                    callback
                );
            });
        }

        public override void callback (GLib.Object? obj, GLib.AsyncResult res) {
            GLib.Variant info;
            try {
                info = portal.get_user_information.end (res);
                if (info == null) {
                    critical ("Account Portal Cancelled");
                    return;
                }

               Variant name = info.lookup_value ("name", VariantType.STRING);
               Variant id = info.lookup_value ("id", VariantType.STRING);
               Variant uri = info.lookup_value ("image", VariantType.STRING);

               name_label.label = (string) name;
               id_label.label = (string) id;
               var path = (string) uri;

               if (path != "") {
                    var file = GLib.Filename.from_uri (path);
                    var pixbuf = new Gdk.Pixbuf.from_file_at_size (
                        file,
                        120,
                        120
                    );
                    avatar.set_from_pixbuf (pixbuf);
               }

               results_box.visible = true;
            }
            catch (Error e){
                results_box.visible = false;
                critical (e.message);
            }
        }
    }
}
