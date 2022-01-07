/* Email.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    public class Pages.Email : Page {
        private AddressList address_list;
        private AddressList cc_list;
        private AddressList bcc_list;
        private Gtk.Button send_button;
        private Gtk.Entry subject_entry;
        private Gtk.Entry body_entry;
        private Gtk.Label result_label;

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

            send_button.clicked.connect (on_send_button_clicked);
        }

        private void on_send_button_clicked () {
            string subject = subject_entry.text;
            string body = body_entry.text;

            result_label.visible = true;
            result_label.remove_css_class ("success");
            result_label.remove_css_class ("warning");
            result_label.remove_css_class ("error");

            if (subject == "") {
                result_label.label = "Subject is empty";
                result_label.add_css_class ("warning");
                return;
            }

            string[] addresses = address_list.retrieve_emails ();
            if (addresses.length == 0) {
                result_label.label = "No addresses have been provided";
                result_label.add_css_class ("warning");
                return;
            }

            string[] cc = cc_list.retrieve_emails ();
            string[] bcc = bcc_list.retrieve_emails ();

            Xdp.Parent parent = Xdp.parent_new_gtk (parent_window);
            portal.compose_email.begin (
                parent,
                addresses,
                cc,
                bcc,
                subject,
                body,
                null,
                NONE,
                null,
                callback
            );
        }

        public override void callback (GLib.Object? obj, GLib.AsyncResult res) {
            bool success;

            try {
                success = portal.compose_email.end (res);

                if (success) {
                    result_label.label = "Request was successful";
                    result_label.add_css_class ("success");
                }
                else {
                    result_label.label = "Request unsucessful";
                    result_label.add_css_class ("warning");
                }
            }
            catch (Error e) {
                critical (e.message);
                result_label.label = e.message;
                result_label.add_css_class ("error");
            }
        }

        public override void build_ui () {
            try {
                var builder = new Gtk.Builder ();
                builder.add_from_resource ("/io/github/diegoivanme/libportal_vala_sample/Email.ui");
                child = builder.get_object ("main_widget") as Gtk.Widget;

                var address_group = builder.get_object ("address_group") as Adw.PreferencesGroup;
                var cc_group = builder.get_object ("cc_group") as Adw.PreferencesGroup;
                var bcc_group = builder.get_object ("bcc_group") as Adw.PreferencesGroup;

                send_button = builder.get_object ("send_button") as Gtk.Button;
                subject_entry = builder.get_object ("subject_entry") as Gtk.Entry;
                body_entry = builder.get_object ("body_entry") as Gtk.Entry;
                result_label = builder.get_object ("result_label") as Gtk.Label;

                address_list = new AddressList ();
                cc_list = new AddressList ();
                bcc_list = new AddressList ();

                address_group.add (address_list);
                cc_group.add (cc_list);
                bcc_group.add (bcc_list);
            }
            catch (Error e) {
                critical ("Error loading UI file: %s", e.message);
            }
        }
    }
}
