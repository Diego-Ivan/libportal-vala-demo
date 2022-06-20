/* Notification.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    // https://valadoc.org/libportal/Xdp.Portal.add_notification.html
    [GtkTemplate (ui = "/io/github/diegoivanme/libportal_vala_sample/Notification.ui")]
    public class Pages.Notification : Page {
        [GtkChild]
        private unowned Adw.EntryRow title_entry;
        [GtkChild]
        private unowned Adw.EntryRow body_entry;
        [GtkChild]
        private unowned Adw.EntryRow id_entry;
        [GtkChild]
        private unowned Gtk.Label result_label;
        [GtkChild]
        private unowned Adw.ComboRow priority_row;

        public const GLib.ActionEntry[] ACTIONS = {
            { "send_action", notification_action }
        };

        public Notification (Xdp.Portal portal_) {
            Object (
                portal: portal_
            );
        }

        construct {
            var action_group = new GLib.SimpleActionGroup ();
            action_group.add_action_entries (ACTIONS, this);
            insert_action_group ("notification", action_group);

            // Handle when the notification action is triggered
            portal.notification_action_invoked.connect ((id, action) => {
                activate_action_variant (action, null);
            });
        }

        [GtkCallback]
        private void on_send_button_clicked () {
            var list = priority_row.model as Gtk.StringList;
            var selected = list.get_string (priority_row.selected);

            var builder = new GLib.VariantBuilder (VariantType.VARDICT); // Building the notification as a Variant using VariantBuilder
            builder.add ("{sv}", "title", new GLib.Variant.string (title_entry.text)); // Set the notification title
            builder.add ("{sv}", "body", new GLib.Variant.string (body_entry.text)); // Set the notification body
            builder.add ("{sv}", "priority", new GLib.Variant.string (selected.ascii_down ())); // Set the notification priority
            builder.add ("{sv}", "default-action", new GLib.Variant.string ("notification.send_action")); // Set the notification default action

            portal.add_notification.begin (
                id_entry.text, // ID of the notification
                builder.end (), // Send the notification as a Variant. As we were using VariantBuilder we call the .end () method
                NONE, // Petition flags. Currently NONE is the only value
                null, // Cancellable, we're using none
                callback // Callback in which we will receive the result of the petition
            );
        }

        public override void callback (GLib.Object? obj, GLib.AsyncResult res) {
            bool result;
            result_label.visible = true;
            try {
                result = portal.add_notification.end (res); // The result is a boolean that indicates if the petition was successful

                if (result) {
                    result_label.label = "Notification sent successfully";
                }
                else {
                    result_label.label = "Notification failed";
                }
            }
            catch (Error e) {
                critical (e.message);
                result_label.label = e.message;
            }
        }

        public void notification_action () {
            message ("Notification action was triggered");
        }
    }
}
