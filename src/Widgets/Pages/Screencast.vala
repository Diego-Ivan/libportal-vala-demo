/* Screencast.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    [GtkTemplate (ui = "/io/github/diegoivanme/libportal_vala_sample/Screencast.ui")]
    public class Pages.Screencast : Page {
        [GtkChild]
        private unowned Gtk.CheckButton monitor_check;
        [GtkChild]
        private unowned Gtk.CheckButton window_check;
        [GtkChild]
        private unowned Gtk.CheckButton virtual_check;
        [GtkChild]
        private unowned Gtk.Switch multi_switch;

        [GtkChild]
        private unowned Gtk.CheckButton hidden_check;
        [GtkChild]
        private unowned Gtk.CheckButton embedded_check;
        [GtkChild]
        private unowned Gtk.CheckButton metadata_check;

        [GtkChild]
        private unowned Gtk.Label status_label;
        [GtkChild]
        private unowned Gtk.Button start_button;
        [GtkChild]
        private unowned Gtk.Button close_button;

        public bool screencast_active { get; private set; }
        public Xdp.Session session { get; private set; }
        private Xdp.OutputType output_types;
        private Xdp.CursorMode cursor_mode;

        public Screencast (Xdp.Portal portal_) {
            Object (
                portal: portal_
            );
        }
        construct {
            screencast_active = false;
            bind_property ("screencast-active",
                start_button, "sensitive",
                SYNC_CREATE | INVERT_BOOLEAN
            );

            bind_property ("screencast-active",
                close_button, "sensitive",
                SYNC_CREATE
            );
        }

        [GtkCallback]
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

        [GtkCallback]
        private void on_close_button_clicked () {
            session.close ();
            screencast_active = false;
            status_label.label = "Session has been closed";
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
    }
}
