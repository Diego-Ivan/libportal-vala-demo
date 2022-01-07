/* EmailRow.vala
 *
 * Copyright 2022 Diego Iván <diegoivan.mae@gmail.com>
 *
 * SPDX-License-Identifier: GPL-3.0-or-later
 */

namespace XdpVala {
    public class EmailRow : Adw.ActionRow {
        public Gtk.Entry email_entry { get; construct; }

        construct {
            email_entry = new Gtk.Entry () {
                valign = CENTER
            };
            add_suffix (email_entry);

            title = "Address";
        }
    }
}
