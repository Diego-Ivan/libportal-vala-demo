/* Notification.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
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
        }

        [GtkCallback]
        private void on_send_button_clicked () {
            var list = priority_row.model as Gtk.StringList;
            var selected = list.get_string (priority_row.selected);

            var builder = new GLib.VariantBuilder (VariantType.VARDICT);
            builder.add ("{sv}", "title", new GLib.Variant.string (title_entry.text));
            builder.add ("{sv}", "body", new GLib.Variant.string (body_entry.text));
            builder.add ("{sv}", "priority", new GLib.Variant.string (selected.ascii_down ()));

            portal.add_notification.begin (
                id_entry.text,
                builder.end (),
                NONE,
                null,
                callback
            );
        }

        public override void callback (GLib.Object? obj, GLib.AsyncResult res) {
            bool result;
            result_label.visible = true;
            try {
                result = portal.add_notification.end (res);

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
