/* Screencast.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    // https://valadoc.org/libportal/Xdp.Portal.create_screencast_session.html
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

        // https://valadoc.org/libportal/Xdp.Session.html
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

            if (!get_output_types ()) return;
            if (!get_cursor_mode ()) return;

            portal.create_screencast_session.begin (
                output_types, // Select the output types: MONITOR, VIRTUAL or WINDOW
                multi_switch.active? Xdp.ScreencastFlags.MULTIPLE : Xdp.ScreencastFlags.NONE, // Whether the screencast allows MULTIPLE streams or not (NONE)
                cursor_mode, // Whether the cursor is EMBEDDED, HIDDEN or sent as METADATA
                NONE, // Whether the screencast should PERSIST, should be TRANSIENT, or NONE (do not persist)
                null, // Restore token. If a screencast configuration was made by the user, the token given should be put here to not show the dialog and immediately apply configurations
                null, // Cancellable. We're using none
                callback // Callback of the function in which we will receive the result of our petition
            );
        }

        [GtkCallback]
        private void on_close_button_clicked () {
            session.close (); // Close the Screencast session
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
                session = portal.create_screencast_session.end (res); // A Xdp.Session will return to us if the petition was successful, and therefore we can start the screencast

                // https://valadoc.org/libportal/Xdp.Parent.html
                Xdp.Parent parent = Xdp.parent_new_gtk (get_native() as Gtk.Window);
                session.start.begin (
                    parent, // Xdp.Parent
                    null, // Cancellable, we're using none
                    session_callback // Callback of the session, in which we will receive if the start of the screencast was successful
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
                screencast_active = session.start.end (res); // A boolean if the Screencast request was successful

                if (screencast_active) {
                    status_label.label = "Screencast is currently active";
                    status_label.add_css_class ("success");

                    // Here, you can open a Pipewire remote using Xdp.Session.open_pipewire_remote () to display your screencast
                    // Later, close your session with Xdp.Session.close ()
                    // Check the Xdp.Session docs to find more useful methods https://valadoc.org/libportal/Xdp.Session.html
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
