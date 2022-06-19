/* Email.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    // https://valadoc.org/libportal/Xdp.Portal.compose_email.html
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

            // Obtain the adressess given by the user
            string[] addresses = address_list.retrieve_emails ();
            if (addresses.length == 0) {
                result_label.label = "No addresses have been provided";
                result_label.add_css_class ("warning");
                return;
            }

            string[] cc = cc_list.retrieve_emails (); // CC lists given by the user
            string[] bcc = bcc_list.retrieve_emails (); // BCC lists given by the user

            // https://valadoc.org/libportal/Xdp.Parent.html
            Xdp.Parent parent = Xdp.parent_new_gtk (get_native () as Gtk.Window);
            portal.compose_email.begin (
                parent, // Xdp.Parent
                addresses, // String array of addresses that the email will be sent to
                cc, // String array of the CC addressess of the email
                bcc, // String array of the BCC addressess of the email
                subject, // Subject of the email
                body, // Body of the email
                null, // Array of file URIs that will be attached to the email. Using none
                NONE, // Flags of the request. Currently, the only value is NONE
                null, // Cancellable, we're using none
                callback // Callback of the function in which we will receive the result of the petition
            );
        }

        public override void callback (GLib.Object? obj, GLib.AsyncResult res) {
            bool success;

            try {
                success = portal.compose_email.end (res); // Know if our request was successful

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
