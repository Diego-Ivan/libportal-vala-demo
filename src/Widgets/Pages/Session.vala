/* Session.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    // https://valadoc.org/libportal/Xdp.Portal.session_inhibit.html
    [GtkTemplate (ui = "/io/github/diegoivanme/libportal_vala_sample/Session.ui")]
    public class Pages.Session : Page {
        [GtkChild]
        private unowned Gtk.Label screensaver_label;
        [GtkChild]
        private unowned Gtk.Label state_label;
        [GtkChild]
        private unowned Gtk.Button start_button;
        [GtkChild]
        private unowned Gtk.Button stop_button;

        [GtkChild]
        private unowned Gtk.CheckButton logout_check;
        [GtkChild]
        private unowned Gtk.CheckButton switch_check;
        [GtkChild]
        private unowned Gtk.CheckButton suspend_check;
        [GtkChild]
        private unowned Gtk.CheckButton idle_check;
        [GtkChild]
        private unowned Adw.EntryRow reason_entry;

        [GtkChild]
        private unowned Adw.PreferencesGroup results_group;
        [GtkChild]
        private unowned Gtk.Label id_label;
        [GtkChild]
        private unowned Gtk.Button inhibit_button;
        [GtkChild]
        private unowned Gtk.Button uninhibit_button;

        private int inhibit_id;
        public bool inhibit_active { get; private set; default = false; }
        public bool monitor_active { get; private set; default = false; }

        public Session (Xdp.Portal portal_) {
            Object (
                portal: portal_
            );
        }

        construct {
            bind_property ("monitor-active",
                start_button, "sensitive",
                SYNC_CREATE | INVERT_BOOLEAN
            );

            bind_property ("monitor-active",
                stop_button, "sensitive",
                SYNC_CREATE
            );

            bind_property ("inhibit-active",
                inhibit_button, "sensitive",
                SYNC_CREATE | INVERT_BOOLEAN
            );

            bind_property ("inhibit-active",
                uninhibit_button, "sensitive",
                SYNC_CREATE
            );
            portal.session_state_changed.connect (on_session_updated);
        }

        [GtkCallback]
        private void on_start_button_clicked () {
            // https://valadoc.org/libportal/Xdp.Parent.html
            Xdp.Parent parent = Xdp.parent_new_gtk (get_native() as Gtk.Window);
            // This function will monitor the session and will tell us its state
            portal.session_monitor_start.begin (
                parent, // Xdp.Parent
                NONE, // Request flags. Currently, the only value is NONE
                null, // Cancellable, using none
                callback // Callback for the petition
            );
        }

        [GtkCallback]
        private void on_stop_button_clicked () {
            portal.session_monitor_stop ();
            monitor_active = false;

            screensaver_label.label = "";
            state_label.label = "";
        }

        [GtkCallback]
        private void on_inhibit_button_clicked () {
            // https://valadoc.org/libportal/Xdp.Parent.html
            Xdp.Parent parent = Xdp.parent_new_gtk (get_native() as Gtk.Window);
            Xdp.InhibitFlags flags = LOGOUT;

            bool logout = logout_check.active;
            bool user_switch = switch_check.active;
            bool suspend = suspend_check.active;
            bool idle = idle_check.active;

            if (!logout && !user_switch && !suspend && !idle)
                return;

            if (!logout)
                flags |= LOGOUT;

            if (user_switch)
                flags |= USER_SWITCH;

            if (suspend)
                flags |= SUSPEND;

            if (idle)
                flags |= IDLE;

            portal.session_inhibit.begin (
                parent, // Xdp.Parent
                reason_entry.text, // Reason to inhibit the session
                flags, // Flags of the petition to inhibit LOGOUT, USER_SWITCH, SUSPEND and/or IDLE
                null, // Cancellable, using none
                inhibit_callback // Callback of the function in which we will receive the result of the petition
            );
        }

        [GtkCallback]
        private void on_uninhibit_button_clicked () {
            portal.session_uninhibit (inhibit_id);
            id_label.label = "";
            inhibit_active = false;
        }

        public override void callback (GLib.Object? obj, GLib.AsyncResult res) {
            try {
                // We will receive a boolean that will indicate if our request was successful
                monitor_active = portal.session_monitor_start.end (res);
            }
            catch (Error e) {
                critical (e.message);
            }
        }

        private void inhibit_callback (GLib.Object? obj, GLib.AsyncResult res) {
            results_group.visible = true;
            try {
                // We will receive the ID of our "inhibit" petition, which we can use later to uninhibit
                inhibit_id = portal.session_inhibit.end (res);
                id_label.label = inhibit_id.to_string ();
                inhibit_active = true;
            }
            catch (Error e) {
                critical (e.message);
                id_label.label = "Failed to start";
            }
        }

        // This method will be called when the LoginSessionState changes and we can query a change
        private void on_session_updated (bool screensaver, Xdp.LoginSessionState state) {
            screensaver_label.label = screensaver.to_string ();

            switch (state) {
                case RUNNING:
                    state_label.label = "Running";
                    break;

                case QUERY_END:
                    state_label.label = "Query End";
                    break;

                case ENDING:
                    state_label.label = "Ending";
                    break;

                default:
                    warn_if_reached ();
                    break;
            }
        }
    }
}
