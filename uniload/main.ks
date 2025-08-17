@LAZYGLOBAL off.

declare local target_module to "".
declare local boot to "network".

declare local mainfile to "main.ks".

deletePath("1:boot/").

core:doevent("open terminal").
set terminal:charheight to 20.

function render_selection_bar {
    parameter choices, labels, cbs.

    declare local out to "".
    declare local separator to " | ".
    declare local char_count to 0.
    declare local lines to list().

    for label in labels {
        if label:length + char_count > terminal:width {
            lines:add(out).
            set out to "".
            set char_count to 0.
        }

        if label:length + char_count + separator:length > terminal:width {
            set out to out + label.
            lines:add(out).
            set out to "".
            set char_count to 0.
        } else {
            set out to out + label + separator.
            set char_count to char_count + label:length + separator:length.
        }
    }
    lines:add(out).

    declare local offset to 0.
    for line in lines {
        print line at(0, terminal:height - lines:length + offset).
        set offset to offset + 1.
    }

    wait until terminal:input:haschar().
    declare local in_char to terminal:input:getchar().
    terminal:input:clear().
    if choices:find(in_char) = -1 = false {
        cbs[choices:find(in_char)]:call().
    }
}

function draw_main_menu {
    clearScreen.
    print("UNIVERSAL LOADER v1.0").
    declare local lines to "".
    for _ in range(0, terminal:width) {
        set lines to lines + "-".
    }
    print(lines).

    print("Boot mode: " + boot).
    if target_module {
        print("Module: " + target_module).
    } else {
        print("Module: None").
    }
    render_selection_bar(list("b", "m", terminal:input:return), list("[b]oot", "[m]odule", "LAUNCH![return]"),list(switch_boot_mode@, module_loader@, launch@)).
}

function switch_boot_mode {
    if boot = "network" {
        set boot to "local".
    } else if boot = "local" {
        set boot to "bare".
    }else if boot = "bare" {
        set boot to "network".
    }
}

function module_loader {
    parameter root_path is "0:".
    declare local root to open(root_path).
    declare local ignored_folders to list("boot", "uniload", "profiles", ".git").

    declare local valids to list().

    for item in root:lex:keys {
        if ignored_folders:find(item) = -1 and check_valid(root_path + "/" + item) {
            valids:add(item).
        }
    }

    declare local selecting to true.
    declare local cursor is 0.

    until not selecting {
        clearScreen.
        declare local c to 0.
        for valid in valids {
            print((choose "-" if cursor = c else " ") + valid + (choose "*" if check_valids_in_children(root_path + "/" + valid) else "")).
            set c to c + 1.
        }
        
        wait until terminal:input:haschar().
        declare local cmd to terminal:input:getchar().
        terminal:input:clear().

        if cmd = terminal:input:downcursorone {
            if cursor < valids:length - 1 {
                set cursor to cursor + 1.
            } else {
                set cursor to 0.
            }
        }
        if cmd = terminal:input:upcursorone {
            if cursor > 0 {
                set cursor to cursor - 1.
            } else {
                set cursor to valids:length - 1.
            }
        }
        if cmd = terminal:input:return {
            set target_module to root_path + "/" + valids[cursor].
            return true.
        }
        if cmd = terminal:input:leftcursorone {
            set selecting to false.
        }
        if cmd = terminal:input:rightcursorone and check_valids_in_children(root_path + "/" + valids[cursor]) {
            if module_loader(root_path + "/" + valids[cursor]) {
                return true.
            }
        }
    }
    
}

function check_valids_in_children{
    parameter root_path.

    for x in open(root_path) {
        if check_valid(root_path + "/" + x:name) {
            return true.
        }
    }
    return false.
}

function check_valid {
    parameter root_path.

    declare local x to open(root_path).
    if not x:isfile and x:lex():keys():find(mainfile) <> -1 {
        return true.
    }
    return false.
}

function launch {

    if not target_module {
        return.
    }

    if boot = "local" {
        clearScreen.
        declare local local_module is target_module:replace("0:", "1:").
        copyPath(target_module, local_module).

        declare local boot_file is core:volume:create("/boot/uni_local_boot.ks").

        boot_file:write("run """ + local_module + "/main.ks"".").
        set core:bootfilename to "boot/uni_local_boot.ks".
        reboot.
    } else if boot = "network" {
        clearScreen.
        set BOOTLOADER_RUNNING to false.
        runpath(target_module + "/main.ks").
    } else if boot = "bare" {
        clearScreen.
        declare local local_module is target_module:replace("0:", "1:").
        copyPath(target_module, local_module).

        set BOOTLOADER_RUNNING to false.
        runpath(local_module + "/main.ks").
    }
}
declare local BOOTLOADER_RUNNING to true.
until not BOOTLOADER_RUNNING {
    draw_main_menu().
}