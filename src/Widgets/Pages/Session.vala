/* Session.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    public class Pages.Session : Page {
        private Gtk.Label screensaver_label;
        private Gtk.Label state_label;
        private Gtk.Button start_button;
        private Gtk.Button stop_button;

        private Gtk.CheckButton logout_check;
        private Gtk.CheckButton switch_check;
        private Gtk.CheckButton suspend_check;
        private Gtk.CheckButton idle_check;
        private Gtk.Entry reason_entry;

        private Adw.PreferencesGroup results_group;
        private Gtk.Label id_label;
        private Gtk.Button inhibit_button;
        private Gtk.Button uninhibit_button;

        private int inhibit_id;
        public bool inhibit_active { get; private set; default = false; }
        public bool monitor_active { get; private set; default = false; }

        public Session (Xdp.Portal portal_) {
            Object (
                portal: portal_,
                title: "Session"
            );
        }

        construct {
            build_ui ();
            var status = child as Adw.StatusPage;
            status.bind_property ("title",
                this, "title",
                SYNC_CREATE | BIDIRECTIONAL
            );

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

            start_button.clicked.connect (on_start_button_clicked);
            stop_button.clicked.connect (on_stop_button_clicked);
            portal.session_state_changed.connect (on_session_updated);

            inhibit_button.clicked.connect (on_inhibit_button_clicked);
            uninhibit_button.clicked.connect (on_uninhibit_button_clicked);
        }

        private void on_start_button_clicked () {
            Xdp.Parent parent = Xdp.parent_new_gtk (get_native() as Gtk.Window);
            portal.session_monitor_start.begin (
                parent,
                NONE,
                null,
                callback
            );
        }

        private void on_stop_button_clicked () {
            portal.session_monitor_stop ();
            monitor_active = false;

            screensaver_label.label = "";
            state_label.label = "";
        }

        private void on_inhibit_button_clicked () {
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
                parent,
                reason_entry.text,
                flags,
                null,
                inhibit_callback
            );
        }

        private void on_uninhibit_button_clicked () {
            portal.session_uninhibit (inhibit_id);
            id_label.label = "";
            inhibit_active = false;
        }

        public override void callback (GLib.Object? obj, GLib.AsyncResult res) {
            try {
                monitor_active = portal.session_monitor_start.end (res);
            }
            catch (Error e) {
                critical (e.message);
            }
        }

        private void inhibit_callback (GLib.Object? obj, GLib.AsyncResult res) {
            results_group.visible = true;
            try {
                inhibit_id = portal.session_inhibit.end (res);
                id_label.label = inhibit_id.to_string ();
                inhibit_active = true;
            }
            catch (Error e) {
                critical (e.message);
                id_label.label = "Failed to start";
            }
        }

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


        public override void build_ui () {
            try {
                var builder = new Gtk.Builder ();
                builder.add_from_resource ("/io/github/diegoivanme/libportal_vala_sample/Session.ui");
                child = builder.get_object ("main_widget") as Gtk.Widget;

                screensaver_label = builder.get_object ("screensaver_label") as Gtk.Label;
                state_label = builder.get_object ("state_label") as Gtk.Label;
                start_button = builder.get_object ("start_button") as Gtk.Button;
                stop_button = builder.get_object ("stop_button") as Gtk.Button;

                logout_check = builder.get_object ("logout_check") as Gtk.CheckButton;
                switch_check = builder.get_object ("switch_check") as Gtk.CheckButton;
                suspend_check = builder.get_object ("suspend_check") as Gtk.CheckButton;
                idle_check = builder.get_object ("idle_check") as Gtk.CheckButton;
                reason_entry = builder.get_object ("reason_entry") as Gtk.Entry;

                results_group = builder.get_object ("results_group") as Adw.PreferencesGroup;
                id_label = builder.get_object ("id_label") as Gtk.Label;
                inhibit_button = builder.get_object ("inhibit_button") as Gtk.Button;
                uninhibit_button = builder.get_object ("uninhibit_button") as Gtk.Button;
            }
            catch (Error e) {
                critical ("Error loading UI file: %s", e.message);
            }
        }
    }
}
