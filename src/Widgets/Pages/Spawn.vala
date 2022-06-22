/* Spawn.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    [GtkTemplate (ui = "/io/github/diegoivanme/libportal_vala_sample/Spawn.ui")]
    public class Pages.Spawn : Page {
        [GtkChild]
        private unowned Gtk.ListBox flags_list;
        [GtkChild]
        private unowned DoubleEntryList env_list;
        [GtkChild]
        private unowned Adw.EntryRow cwd_entry;
        [GtkChild]
        private unowned EntryList arg_list;
        [GtkChild]
        private unowned Adw.PreferencesGroup results_group;
        [GtkChild]
        private unowned Gtk.Label pid_label;
        [GtkChild]
        private unowned Gtk.Label status_label;

        private ListStore model = new ListStore (typeof(FlagObject));

        public Spawn (Xdp.Portal portal_) {
            Object (portal: portal_);
        }

        static construct {
            typeof (DoubleEntryList).ensure ();
        }

        construct {
            model.append (new FlagObject ("ClearEnv"));
            model.append (new FlagObject ("Latest"));
            model.append (new FlagObject ("Sandbox"));
            model.append (new FlagObject ("No-Network"));
            model.append (new FlagObject ("Watch"));

            flags_list.bind_model (model, widget_creation);
            portal.spawn_exited.connect (on_spawn_exited);
        }

        [GtkCallback]
        private void on_spawn_button_clicked () {
            string[]? args = arg_list.retrieve_strings ();
            string[]? env = env_list.retrieve_strings ();

            if (args.length == 0 || env.length == 0) {
                args = null;
                env = null;
            }

            portal.spawn.begin (
                cwd_entry.text, // Command to Run
                args, // argv list to parse to the command
                null, // fds for the process, using none
                null, // array of integers to map to the fds, using none
                env, // ENV variables for the program
                get_spawn_flags (), // Flags for the Program: CLEARENV, LATEST, SANDBOX, NO_NETWORK, WATCH or NONE
                null, // R/W paths to expose to the sandbox, using none
                null, // RO paths to expose to the sandbox, using none
                null, // Cancellable. Using none
                callback // Callback of the function
            );
        }

        public override void callback (GLib.Object? obj, GLib.AsyncResult res) {
            int pid;
            try {
                results_group.visible = true;
                pid = portal.spawn.end (res);
                pid_label.label = pid.to_string ();
                status_label.label = "Process Running";
            }
            catch (Error e) {
                error (e.message);
            }
        }

        private void on_spawn_exited (uint pid, uint exit_status) {
            status_label.label = "Process with pid %u exited with status %u".printf (pid, exit_status);
        }

        private Xdp.SpawnFlags get_spawn_flags () {
            Xdp.SpawnFlags flags = NONE;
            for (int i = 0; i < model.get_n_items (); i++) {
                FlagObject o = (FlagObject) model.get_item (i);
                FlagRow row = (FlagRow) flags_list.get_row_at_index (i);

                if (!row.selected)
                    continue;

                switch (o.name) {
                    case "ClearEnv":
                        flags |= CLEARENV;
                        break;
                    case "Latest":
                        flags |= LATEST;
                        break;
                    case "Sandbox":
                        flags |= SANDBOX;
                        break;
                    case "No-Network":
                        flags |= NO_NETWORK;
                        break;
                    case "Watch":
                        flags |= WATCH;
                        break;
                }
            }

            return flags;
        }

        private Gtk.Widget widget_creation (Object item) {
            return new FlagRow ((FlagObject) item);
        }
    }

    internal class FlagObject : Object {
        public string name { get; set; }
        public FlagObject (string n) {
            Object (name: n);
        }
    }

    internal class FlagRow : Adw.ActionRow {
        private Gtk.CheckButton check_button = new Gtk.CheckButton ();
        public bool selected {
            get {
                return check_button.active;
            }
        }

        public FlagRow (FlagObject o) {
            title = o.name;
        }

        construct {
            add_prefix (check_button);
            activatable_widget = check_button;
        }
    }
}
