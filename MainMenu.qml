import QtQuick 2.10
import QtQuick.Controls 2.3
import Qt.labs.platform 1.0
import QtQuick.Controls 1.2 as Controls

Controls.MenuBar {
        id: mainMenu
        Controls.Menu {
            title: "Файл"
            Controls.MenuItem {
                text: "Lorem"
            }
            Controls.MenuItem {
                text: "Lorem iet"
            }
            Controls.MenuItem {
                text: "Lore itemm"
            }
        }
        Controls.Menu {
            title: "Изменить"
            Controls.MenuItem {
                text: "Lorem"
            }
            Controls.MenuItem {
                text: "Lorem"
            }
        }
        Controls.Menu {
            title: "Вид"
            Controls.MenuItem {
                text: "Lorem"
            }
            Controls.MenuItem {
                text: "Lorem"
            }
        }
        Controls.Menu {
            title: "Помощь"
            Controls.MenuItem {
                text: "Lorem"
            }
        }
        Controls.Menu {
            title: "О программе"
            Controls.MenuItem {
                text: "Lorem"
            }
        }
    }
