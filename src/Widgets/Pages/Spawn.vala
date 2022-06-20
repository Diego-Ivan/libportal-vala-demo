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
        }

        [GtkCallback]
        private void on_spawn_button_clicked () {
            string[] strings = env_list.retrieve_strings ();
            foreach (var str in strings) {
                message (str);
            }
            get_spawn_flags ();
        }

        public override void callback (GLib.Object? obj, GLib.AsyncResult res) {
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
