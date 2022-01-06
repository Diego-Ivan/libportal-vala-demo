/* Account.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    public class Pages.Account : Page {
        private Gtk.Image avatar;
        private Gtk.Entry reason_entry;
        private Gtk.Button request_button;
        private Gtk.Label name_label;
        private Gtk.Label id_label;
        private Gtk.Box results_box;
        private bool request_succesful { get; set; }

        public Account (Xdp.Portal portal_, Gtk.Window parent_win) {
            Object (
                portal: portal_,
                parent_window: parent_win,
                title: "Accounts"
            );
        }

        construct {
            title = "Accounts";
            build_ui ();
            request_button.clicked.connect (() => {

                if (reason_entry.text == "") {
                    reason_entry.add_css_class ("error");
                    return;
                }
                else {
                    reason_entry.remove_css_class ("error");
                }

                var parent = Xdp.parent_new_gtk (parent_window);

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

        public override void build_ui () {
            var builder = new Gtk.Builder ();
            try {
                builder.add_from_resource ("/io/github/diegoivanme/libportal_vala_sample/Accounts.ui");
                child = builder.get_object ("main_widget") as Gtk.Widget;

                avatar = builder.get_object ("avatar") as Gtk.Image;
                reason_entry = builder.get_object ("reason_entry") as Gtk.Entry;
                request_button = builder.get_object ("request_button") as Gtk.Button;
                name_label = builder.get_object ("name_label") as Gtk.Label;
                id_label = builder.get_object ("id_label") as Gtk.Label;
                results_box = builder.get_object ("results_box") as Gtk.Box;

                var status = child as Adw.StatusPage;
                status.bind_property ("title",
                    this, "title",
                    SYNC_CREATE | BIDIRECTIONAL
                );
            }
            catch (Error e) {
                critical ("Error loading UI file: %s", e.message);
            }
        }
    }
}
