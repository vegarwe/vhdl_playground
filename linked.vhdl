use std.textio.all ;

library ieee ;
use ieee.std_logic_1164.all ;
use ieee.numeric_std.all ;


package linked is
    type linked_item;
    type linked_list is access linked_item; --pointer to item

    type linked_item is record
        value : integer;
        next_item : linked_list;
    end record;

    procedure linked_insert(variable Head : inout linked_list; constant value : in integer);
    procedure linked_append(variable Head : inout linked_list; constant value : in integer);
    procedure linked_free(variable Head : inout linked_list);

  -- function inside (constant E : ElementType; constant A : in ArrayofElementType) return boolean ;
end linked ;

package body linked is

    procedure linked_insert(variable Head : inout linked_list; constant value : in integer) is
        variable Ptr : linked_list;
    begin
        if Head = null then
            Head := new linked_item;
            Head.value := value;
            return;
        end if;

        Ptr := new linked_item;
        Ptr.value := value;

        Ptr.next_item := Head.next_item;
        Head.next_item := Ptr;
    end procedure;


    procedure linked_append(variable Head : inout linked_list; constant value : in integer) is
        variable Ptr : linked_list;
    begin
        if Head = null then
            Head := new linked_item;
            Head.value := value;
            return;
        end if;

        Ptr := Head;
        while Ptr.next_item /= null loop
            Ptr := Ptr.next_item;
        end loop;

        Ptr.next_item := new linked_item;
        Ptr.next_item.value := value;
    end procedure;


    procedure linked_free(variable Head : inout linked_list) is
        variable Ptr : linked_list;
    begin
        while Head /= null loop
            Ptr := Head.next_item;
            --report "Deallocating " & integer'image(Head.value);
            DEALLOCATE(Head);
            Head := Ptr;
        end loop;
    end procedure;

end linked ;

