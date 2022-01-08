/* Notification.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    public class Pages.Notification : Page {
        private Gtk.Entry title_entry;
        private Gtk.Entry body_entry;
        private Gtk.Entry id_entry;
        private Gtk.Label result_label;
        private Adw.ComboRow priority_row;
        private Gtk.Button send_button;

        public const GLib.ActionEntry[] ACTIONS = {
            { "send_action", notification_action }
        };

        public Notification (Xdp.Portal portal_, Gtk.Window parent_win) {
            Object (
                portal: portal_,
                parent_window: parent_win,
                title: "Notification"
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

            var action_group = new GLib.SimpleActionGroup ();
            action_group.add_action_entries (ACTIONS, this);
            insert_action_group ("notification", action_group);

        }

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

        public override void build_ui () {
            try {
                var builder = new Gtk.Builder ();
                builder.add_from_resource ("/io/github/diegoivanme/libportal_vala_sample/Notification.ui");
                child = builder.get_object ("main_widget") as Gtk.Widget;

                title_entry = builder.get_object ("title_entry") as Gtk.Entry;
                body_entry = builder.get_object ("body_entry") as Gtk.Entry;
                id_entry = builder.get_object ("id_entry") as Gtk.Entry;
                priority_row = builder.get_object ("priority_row") as Adw.ComboRow;
                send_button = builder.get_object ("send_button") as Gtk.Button;
                result_label = builder.get_object ("result_label") as Gtk.Label;
            }
            catch (Error e) {
                critical ("Error loading UI file: %s", e.message);
            }
        }
    }
}
