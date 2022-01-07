/* Email.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    public class Pages.Email : Page {
        private AddressList address_list;
        public Email (Xdp.Portal portal_, Gtk.Window parent_win) {
            Object (
                portal: portal_,
                parent_window: parent_win,
                title: "Email"
            );
        }

        construct {
            build_ui ();
            var status = child as Adw.StatusPage;
            status.bind_property ("title",
                this, "title",
                SYNC_CREATE | BIDIRECTIONAL
            );
        }

        public override void callback (GLib.Object? obj, GLib.AsyncResult res) {
        }

        public override void build_ui () {
            try {
                var builder = new Gtk.Builder ();
                builder.add_from_resource ("/io/github/diegoivanme/libportal_vala_sample/Email.ui");
                child = builder.get_object ("main_widget") as Gtk.Widget;

                var address_group = builder.get_object ("address_group") as Adw.PreferencesGroup;

                address_list = new AddressList ();
                address_group.add (address_list);

                var button = new Gtk.Button ();
                button.clicked.connect (() => {
                    var strings = address_list.retrieve_emails ();

                    for (int i=0; i < strings.length; i++) {
                        message (strings[i]);
                    }
                });
            }
            catch (Error e) {
                critical ("Error loading UI file: %s", e.message);
            }
        }
    }
}
