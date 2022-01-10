/* Screencast.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    public class Pages.Screencast : Page {
        private Gtk.CheckButton monitor_check;
        private Gtk.CheckButton window_check;
        private Gtk.CheckButton virtual_check;
        private Gtk.Switch multi_switch;

        private Gtk.CheckButton hidden_check;
        private Gtk.CheckButton embedded_check;
        private Gtk.CheckButton metadata_check;

        private Gtk.Label status_label;
        private Gtk.Button start_button;
        private Gtk.Button close_button;

        public bool screencast_active { get; private set; }
        public Xdp.Session session { get; private set; }
        private Xdp.OutputType output_types;
        private Xdp.CursorMode cursor_mode;

        public Screencast (Xdp.Portal portal_) {
            Object (
                portal: portal_,
                title: "Screencast"
            );
        }
        construct {
            build_ui ();
            var status = child as Adw.StatusPage;
            status.bind_property ("title",
                this, "title",
                SYNC_CREATE | BIDIRECTIONAL
            );

            screencast_active = false;
            bind_property ("screencast-active",
                start_button, "sensitive",
                SYNC_CREATE | INVERT_BOOLEAN
            );

            bind_property ("screencast-active",
                close_button, "sensitive",
                SYNC_CREATE
            );

            start_button.clicked.connect (on_start_button_clicked);
            close_button.clicked.connect (on_close_button_clicked);
        }

        private void on_start_button_clicked () {
            status_label.visible = true;
            status_label.remove_css_class ("error");
            status_label.remove_css_class ("success");

            bool multiple = multi_switch.active;
            Xdp.ScreencastFlags screencast_flags = multiple?
                Xdp.ScreencastFlags.NONE :
                Xdp.ScreencastFlags.MULTIPLE;

            if (!get_output_types ()) return;
            if (!get_cursor_mode ()) return;

            portal.create_screencast_session.begin (
                output_types,
                screencast_flags,
                cursor_mode,
                NONE,
                null,
                null,
                callback
            );
        }

        private bool get_output_types () {
            output_types = MONITOR;
            bool monitor = monitor_check.active;
            bool window = window_check.active;
            bool virt = virtual_check.active;

            if (!monitor && !window && !virt) {
                output_types ^= MONITOR;
                status_label.label = "Select at least one output";
                return false;
            }

            if (!monitor) {
                output_types ^= MONITOR;
            }

            if (window) {
                output_types |= WINDOW;
            }

            if (virt) {
                output_types |= VIRTUAL;
            }

            return true;
        }

        private bool get_cursor_mode () {
            cursor_mode = HIDDEN;
            bool hidden = hidden_check.active;
            bool embedded = embedded_check.active;
            bool metadata = metadata_check.active;

            if (!hidden && !embedded && !metadata) {
                cursor_mode^= HIDDEN;
                status_label.label = "Select at least one cursor mode";
                return false;
            }

            if (!hidden) {
                cursor_mode ^= HIDDEN;
            }

            if (embedded) {
                cursor_mode |= EMBEDDED;
            }

            if (metadata) {
                cursor_mode |= METADATA;
            }

            return true;
        }

        public override void callback (GLib.Object? obj, GLib.AsyncResult res) {
            try {
                session = portal.create_screencast_session.end (res);

                Xdp.Parent parent = Xdp.parent_new_gtk (get_native() as Gtk.Window);
                session.start.begin (
                    parent,
                    null,
                    session_callback
                );
            }
            catch (Error e) {
                critical (e.message);
                status_label.label = e.message;
                status_label.add_css_class ("error");
            }
        }

        private void session_callback (GLib.Object? obj, GLib.AsyncResult res) {
            try {
                screencast_active = session.start.end (res);

                if (screencast_active) {
                    status_label.label = "Screencast is currently active";
                    status_label.add_css_class ("success");
                }
                else {
                    status_label.label = "Screencast failed to start";
                    status_label.add_css_class ("error");
                }
            }
            catch (Error e) {
                critical (e.message);
                status_label.label = e.message;
                status_label.add_css_class ("error");
            }
        }

        private void on_close_button_clicked () {
            session.close ();
            screencast_active = false;
            status_label.label = "Session has been closed";
        }

        public override void build_ui () {
            try {
                var builder = new Gtk.Builder ();
                builder.add_from_resource ("/io/github/diegoivanme/libportal_vala_sample/Screencast.ui");
                child = builder.get_object ("main_widget") as Gtk.Widget;

                monitor_check = builder.get_object ("monitor_check") as Gtk.CheckButton;
                window_check = builder.get_object ("window_check") as Gtk.CheckButton;
                virtual_check = builder.get_object ("virtual_check") as Gtk.CheckButton;
                multi_switch = builder.get_object ("multi_switch") as Gtk.Switch;

                hidden_check = builder.get_object ("hidden_check") as Gtk.CheckButton;
                embedded_check = builder.get_object ("embedded_check") as Gtk.CheckButton;
                metadata_check = builder.get_object ("metadata_check") as Gtk.CheckButton;

                status_label = builder.get_object ("status_label") as Gtk.Label;
                start_button = builder.get_object ("start_button") as Gtk.Button;
                close_button = builder.get_object ("close_button") as Gtk.Button;
            }
            catch (Error e) {
                critical ("Error loading UI file: %s", e.message);
            }
        }
    }
}
