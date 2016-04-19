use std.textio.all;

library ieee;
    use ieee.numeric_std.all;
    use ieee.std_logic_1164.all;

library work;
    use work.linked.all;

entity linked_tb is
end linked_tb;

architecture behav of linked_tb is
begin
    process
        variable if_data, ptr : linked_list;
    begin
        linked_insert(if_data, 0);
        linked_insert(if_data, 1);
        linked_insert(if_data, 2);
        linked_insert(if_data, 3);
        linked_append(if_data, 4);

        ptr := if_data;
        while ptr /= null loop
            report "Iteration " & integer'image(ptr.value);
            ptr := ptr.next_item;
        end loop;

        linked_free(if_data);

        wait;
    end process;
end behav;
