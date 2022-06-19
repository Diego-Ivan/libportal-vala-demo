/* Email.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    [GtkTemplate (ui = "/io/github/diegoivanme/libportal_vala_sample/Email.ui")]
    public class Pages.Email : Page {
        [GtkChild]
        private unowned AddressList address_list;
        [GtkChild]
        private unowned AddressList cc_list;
        [GtkChild]
        private unowned AddressList bcc_list;
        [GtkChild]
        private unowned Adw.EntryRow subject_entry;
        [GtkChild]
        private unowned Adw.EntryRow body_entry;
        [GtkChild]
        private unowned Gtk.Label result_label;

        public Email (Xdp.Portal portal_) {
            Object (
                portal: portal_
            );
        }

        [GtkCallback]
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

            Xdp.Parent parent = Xdp.parent_new_gtk (get_native () as Gtk.Window);
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
                    result_label.label = "Request unsuccessful";
                    result_label.add_css_class ("warning");
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
