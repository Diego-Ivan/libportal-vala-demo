/* AddressList.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    public class AddressList : Adw.Bin {
        public Adw.PreferencesRow new_address_row { get; protected set; }
        private Gtk.ListBox listbox = new Gtk.ListBox () {
            selection_mode = NONE
        };

        construct {
            listbox.add_css_class ("content");
            child = listbox;

            new_address_row = new Adw.PreferencesRow () {
                child = new Gtk.Label ("Add a new Address") {
                    margin_top = 12,
                    margin_bottom = 12
                }
            };
            listbox.append (new_address_row);

            listbox.row_activated.connect ((row) => {
                if (row != new_address_row)
                    return;
                add_new_address ();
            });

            add_new_address ();
        }

        private void add_new_address () {
            listbox.remove (new_address_row);

            var n_row = new Adw.EntryRow () {
                title = "Email"
            };
            n_row.grab_focus ();
            listbox.append (n_row);

            listbox.append (new_address_row);
        }

        public string[] retrieve_emails () {
            string[] emails = {};
            int index = 0;

            var list = child as Gtk.ListBox;
            Gtk.ListBoxRow? current_row;
            current_row = list.get_row_at_index (index);

            while (current_row != null) {
                if (current_row == new_address_row)
                    break;

                var e_row = current_row as Adw.EntryRow;
                string email = e_row.text;

                if (email == "") {
                    warning ("Row %i is empty", index);
                    e_row.add_css_class ("error");
                }
                else {
                    emails = emails + email;
                    e_row.remove_css_class ("error");
                }

                index++;
                current_row = list.get_row_at_index (index); // go to the next row
            }
            return emails;
        }
    }
}
