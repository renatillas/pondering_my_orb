-module(iv).
-compile([no_auto_import, nowarn_unused_vars, nowarn_unused_function, nowarn_nomatch, inline]).
-define(FILEPATH, "src/iv.gleam").
-export([new/0, wrap/1, from_list/1, from_reverse_list/1, from_yielder/1, to_yielder/1, initialise/2, repeat/2, range/2, is_empty/1, size/1, length/1, equal/2, get/2, first/1, last/1, at/2, get_or_default/3, find_map/2, find/2, any/2, all/2, contains/2, find_index/2, index_of/2, find_last_index/2, last_index_of/2, update/3, set/3, try_update/3, try_set/3, try_swap_delete/2, swap_delete/2, concat/2, append/2, append_list/2, append_reverse_list/2, prepend/2, prepend_list/2, prepend_reverse_list/2, concat_list/1, split/2, insert/3, insert_clamped/3, insert_list/3, insert_list_clamped/3, splice/4, replace/4, drop_first/2, take_first/2, delete/2, try_delete/2, drop_last/2, take_last/2, sized_chunk/2, split_n/2, rest/1, leading/1, slice_clamped/3, slice/3, map/2, index_map/2, try_map/2, map2/3, zip/2, fold/3, join/2, flatten/1, flat_map/2, filter/2, filter_map/2, each/2, index_fold/3, fold_right/3, to_list/1, reverse/1, each_right/2, index_fold_right/3, try_fold/3, try_each/2]).
-export_type([array/1]).

-if(?OTP_RELEASE >= 27).
-define(MODULEDOC(Str), -moduledoc(Str)).
-define(DOC(Str), -doc(Str)).
-else.
-define(MODULEDOC(Str), -compile([])).
-define(DOC(Str), -compile([])).
-endif.

?MODULEDOC(
    " <style>\n"
    "   small {\n"
    "     font-size: 0.7em;\n"
    "     opacity: 0.75;\n"
    "   }\n"
    "   h4 {\n"
    "     margin-bottom: 0;\n"
    "     + p {\n"
    "       margin-top: 0;\n"
    "     }\n"
    "   }\n"
    " </style>\n"
    " <script>\n"
    " (callback => document.readyState !== 'loading' ? callback() : document.addEventListener('DOMContentLoaded', callback, { once: true }))(() => {\n"
    "   const list = document.querySelector('.sidebar > ul:last-of-type')\n"
    "   const sortedLists = document.createDocumentFragment()\n"
    "   const sortedMembers = document.createDocumentFragment()\n"
    "\n"
    "   for (const header of document.querySelectorAll('main > h4')) {\n"
    "     sortedLists.append((() => {\n"
    "       const node = document.createElement('h3')\n"
    "       node.append(header.textContent)\n"
    "       return node\n"
    "     })())\n"
    "     sortedMembers.append((() => {\n"
    "       const node = document.createElement('h2')\n"
    "       node.append(header.textContent)\n"
    "       return node\n"
    "     })())\n"
    "\n"
    "     const sortedList = document.createElement('ul')\n"
    "     sortedLists.append(sortedList)\n"
    "\n"
    "     for (const anchor of header.nextElementSibling.querySelectorAll('a')) {\n"
    "       const href = anchor.getAttribute('href')\n"
    "       const member = document.querySelector(`.member:has(h2 > a[href=\"${href}\"])`)\n"
    "       const sidebar = list.querySelector(`li:has(a[href=\"${href}\"])`)\n"
    "       sortedList.append(sidebar)\n"
    "       sortedMembers.append(member)\n"
    "     }\n"
    "   }\n"
    "\n"
    "   document.querySelector('.sidebar').insertBefore(sortedLists, list)\n"
    "   document.querySelector('.module-members:has(#module-values)').insertBefore(sortedMembers, document.querySelector('#module-values').nextSibling)\n"
    " })\n"
    " </script>\n"
    "\n"
    " `iv` is an immutable array structure written in Gleam. You can use it\n"
    " like you would use an array in other programming languages and expect\n"
    " comparable or better runtime characteristics.\n"
    "\n"
    " **Tip:** Hover the links for short summaries!\n"
    "\n"
    " #### Create & Convert\n"
    " [new](#new \"Create an empty array\"),\n"
    " [wrap](#wrap \"A single element\"),\n"
    " [repeat](#repeat \"Repeat a single element\"),\n"
    " [from_list](#from_list \"Convert a list to an array\"),\n"
    " [from_reverse_list](#from_reverse_list \"Convert a reversed list to an array\"),\n"
    " [from_yielder](#from_yielder \"Consume any yielder to build an array\"),\n"
    " [initialise](#initialise \"Use a constructor function for every element\") \\\n"
    " [to_list](#to_list \"Convert to a list\"),\n"
    " [to_yielder](#to_yielder \"Create a yielder iterating through the array\"),\n"
    " [join](#join \"Convert a string array to a string\")\n"
    "\n"
    " #### Query\n"
    " [is_empty](#is_empty \"Is the array empty?\"),\n"
    " [size](#size \"Number of elements\"),\n"
    " [equal](#equal \"Are 2 arrays equal?\"),\n"
    " [any](#any \"Does any element have a property?\"),\n"
    " [all](#all \"Do all elements have a property?\") \\\n"
    " [contains](#contains \"Does the array contain an element?\"),\n"
    " [index_of](#index_of \"Get the index of an element\"),\n"
    " [last_index_of](#last_index_of \"Get index of an element from the end\"),\n"
    " [get](#get \"Get the element at an index\"),\n"
    " [get_or_default](#get_or_default \"Get the element at an index or a fallback value\"),\n"
    " [at](#at \"Get the element at an index\"),\n"
    " [find](#find \"Find the first element with a property\"),\n"
    " [find_index](#find_index \"Find the index of the first element with a property\"),\n"
    " [find_last_index](#find_last_index \"Find the index of the last element with a property\"),\n"
    " [find_map](#find_map \"Find the first Ok(_)\")\n"
    "\n"
    " #### Manipulate\n"
    "\n"
    " [set](#set \"Set an element\"),\n"
    " [try_set](#try_set \"Set an element if the index exists\"),\n"
    " [update](#update \"Update an element\"),\n"
    " [try_update](#try_update \"Update an element if the index exists\")\n"
    " [insert](#insert \"Insert an element\"),\n"
    " [insert_clamped](#insert_clamped \"Insert, prepend, or append an element\"),\n"
    " [insert_list](#insert_list \"Insert many elements\"),\n"
    " [insert_list_clamped](#insert_list_clamped \"Insert, prepend, or append many elements\"),\n"
    " [delete](#delete \"Delete an element\"),\n"
    " [try_delete](#try_delete \"Delete an element, if it exists\") \\\n"
    " [swap_delete](#swap_delete \"Swap an element with the last, then delete the last element\"),\n"
    " [try_swap_delete](#try_swap_delete \"Swan an element with the last, then delete the last element\") \\\n"
    " [append](#append \"Add an element to the end\"),\n"
    " [append_list](#append_list \"Add many elements to the end\"),\n"
    " [append_reverse_list](#append_reverse_list \"Add many elements to the end, in reverse order\"),\n"
    " [prepend](#prepend \"Add an element at the start\"),\n"
    " [prepend_list](#prepend_list \"Add many elements at the start\"),\n"
    " [prepend_reverse_list](#prepend_reverse_list \"Add many elements at the start, in reverse order\"),\n"
    " [replace](#replace \"Replace a range of elements\"),\n"
    " [splice](#splice \"Replace a range of elements using a function\")\n"
    "\n"
    " #### Concatenate & Split\n"
    " [concat](#concat \"Concatenate two arrays\"),\n"
    " [concat_list](#concat_list \"Concatenate many arrays\"),\n"
    " [flatten](#flatten \"Concatenate nested arrays\"),\n"
    " [split](#split \"Split an array at an index\"),\n"
    " [split_n](#split_n \"N-way split\")\n"
    " [slice](#slice \"Get a slice of the array\"),\n"
    " [slice_clamped](#slice_clamped \"Get a slice of the array\"),\n"
    " [drop_first](#drop_first \"Remove the first elements\"),\n"
    " [drop_last](#drop_last \"Remove the last elements\"),\n"
    " [take_first](#take_first \"Take the first elements\"),\n"
    " [take_last](#take_last \"Take the last elements\"),\n"
    " [sized_chunk](#sized_chunk \"Split an array into chunks\")\n"
    "\n"
    " #### Transform\n"
    " [reverse](#reverse \"Reverse the order\"),\n"
    " [map](#map \"Transform every element\"),\n"
    " [try_map](#try_map \"Transform every element using a fallible function\"),\n"
    " [index_map](#index_map \"Transform every element using its index\"),\n"
    " [flat_map](#flat_map \"Map every element to anoher array\"),\n"
    " [filter](#filter \"Filter elements based on a property\"),\n"
    " [filter_map](#filter_map \"Collect all Ok values\"),\n"
    " [zip](#zip \"Combine elements of 2 arrays\"),\n"
    " [map2](#map2 \"Combine 2 arrays usng a function\")\n"
    "\n"
    " #### Looping\n"
    " [each](#each \"Loop start to end\"),\n"
    " [try_each](#try_each \"Loop until error\"),\n"
    " [each_right](#each_right \"Loop end to start\"),\n"
    " [fold](#fold \"Loop start to end, with state\"),\n"
    " [index_fold](#index_fold \"Loop start to end, with index and state\"),\n"
    " [try_fold](#try_fold \"Loop until error, with state\"),\n"
    " [fold_right](#fold_right \"Loop end to start, with state\"),\n"
    " [index_fold_right](#index_fold_right \"Loop end to start, with index and state\")\n"
).

-opaque array(HTG) :: empty | {array, integer(), iv@internal@node:node_(HTG)}.

-file("src/iv.gleam", 167).
-spec array(integer(), iv@internal@vector:vector(iv@internal@node:node_(HTH))) -> array(HTH).
array(Shift, Nodes) ->
    case erlang:tuple_size(Nodes) of
        0 ->
            empty;

        1 ->
            {array, Shift, erlang:element(1, Nodes)};

        _ ->
            Shift@1 = Shift + 4,
            {array, Shift@1, iv@internal@node:branch(Shift@1, Nodes)}
    end.

-file("src/iv.gleam", 192).
?DOC(
    " Returns a new empty array.\n"
    "\n"
    " ```gleam\n"
    " new()\n"
    " // --> from_list([])\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec new() -> array(any()).
new() ->
    empty.

-file("src/iv.gleam", 211).
?DOC(
    " Returns the given item wrapped in a list.\n"
    "\n"
    " ```gleam\n"
    " wrap(42)\n"
    " // --> from_list([42])\n"
    "\n"
    " wrap(from_list([1, 2, 3]))\n"
    " // --> from_list([from_list([1, 2, 3])])\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec wrap(HTM) -> array(HTM).
wrap(Item) ->
    {array, 0, {leaf, iv_ffi:singleton(Item)}}.

-file("src/iv.gleam", 227).
?DOC(
    " Converts the given list to an array.\n"
    "\n"
    " ```gleam\n"
    " length(from_list([1, 2, 3]))\n"
    " // --> 3\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec from_list(list(HTO)) -> array(HTO).
from_list(List) ->
    case begin
        _pipe = List,
        _pipe@1 = gleam@list:fold(
            _pipe,
            iv@internal@builder:new(),
            fun iv@internal@builder:push/2
        ),
        iv@internal@builder:build(_pipe@1)
    end of
        {ok, {Shift, Nodes}} ->
            array(Shift, Nodes);

        {error, _} ->
            empty
    end.

-file("src/iv.gleam", 258).
?DOC(
    " Convert the given list to an array that contains all items in the reverse\n"
    " order from the original list.\n"
    "\n"
    " Equivalent to `iv.from_list(list.reverse(items))`.\n"
    "\n"
    " This is useful as the last step in a tail-recursive algorithm building up a\n"
    " list as an intermediary. Instead of calling `list.reverse` and then\n"
    " converting the final list to an array, it's faster to use this function\n"
    " instead!\n"
    "\n"
    " ```gleam\n"
    " from_reverse_list([1, 2, 3])\n"
    " // --> from_list([3, 2, 1])\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec from_reverse_list(list(HTR)) -> array(HTR).
from_reverse_list(List) ->
    case begin
        _pipe = List,
        _pipe@1 = gleam@list:fold(
            _pipe,
            iv@internal@builder:reverse(),
            fun iv@internal@builder:push/2
        ),
        iv@internal@builder:build(_pipe@1)
    end of
        {ok, {Shift, Nodes}} ->
            array(Shift, Nodes);

        {error, _} ->
            empty
    end.

-file("src/iv.gleam", 285).
?DOC(
    " Consume the given yielder, collecting all elements into a new array.\n"
    "\n"
    " ```gleam\n"
    " from_yielder(\n"
    "   yielder.range(1, 3)\n"
    "   |> yielder.cycle()\n"
    "   |> yielder.take(10)\n"
    " )\n"
    " // --> from_list([1, 2, 3, 1, 2, 3, 1, 2, 3, 1])\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec from_yielder(gleam@yielder:yielder(HTU)) -> array(HTU).
from_yielder(Source) ->
    case begin
        _pipe = Source,
        _pipe@1 = gleam@yielder:fold(
            _pipe,
            iv@internal@builder:new(),
            fun iv@internal@builder:push/2
        ),
        iv@internal@builder:build(_pipe@1)
    end of
        {ok, {Shift, Nodes}} ->
            array(Shift, Nodes);

        {error, _} ->
            empty
    end.

-file("src/iv.gleam", 331).
?DOC(
    " Return a yielder iterating through an array.\n"
    "\n"
    " Yielders are more efficient then repeatetly querying the index, but slower\n"
    " than using more specialised functions like [each](#each) or [fold](#fold).\n"
    " Only use this if you need to pause or iterate through many arrays at once.\n"
    "\n"
    " ```gleam\n"
    " to_yielder(from_list([1, 2, 3]))\n"
    " |> yielder.cycle\n"
    " |> yielder.take(10)\n"
    " |> yielder.to_list\n"
    " // --> [1, 2, 3, 1, 2, 3, 1, 2, 3, 1]\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec to_yielder(array(HUA)) -> gleam@yielder:yielder(HUA).
to_yielder(Array) ->
    case Array of
        empty ->
            gleam@yielder:empty();

        {array, _, Root} ->
            iv@internal@iterator:new(Root)
    end.

-file("src/iv.gleam", 421).
-spec initialise_loop(
    integer(),
    integer(),
    iv@internal@builder:builder(IIG),
    fun((integer()) -> IIG)
) -> {ok, {integer(), iv@internal@vector:vector(iv@internal@node:node_(IIG))}} |
    {error, nil}.
initialise_loop(Idx, Length, Builder, Fun) ->
    case Idx < Length of
        true ->
            initialise_loop(
                Idx + 1,
                Length,
                iv@internal@builder:push(Builder, Fun(Idx)),
                Fun
            );

        false ->
            iv@internal@builder:build(Builder)
    end.

-file("src/iv.gleam", 414).
?DOC(
    " Create a list using a constructor function for each element.\n"
    " The function receives the current index as an input.\n"
    "\n"
    " ```gleam\n"
    " initialise(5, fn(i) { i * 2 })\n"
    " // --> from_list([0, 2, 4, 6, 8])\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec initialise(integer(), fun((integer()) -> HUH)) -> array(HUH).
initialise(Length, Fun) ->
    case initialise_loop(0, Length, iv@internal@builder:new(), Fun) of
        {ok, {Shift, Nodes}} ->
            array(Shift, Nodes);

        {error, _} ->
            empty
    end.

-file("src/iv.gleam", 374).
?DOC(
    " Build an array by repeating the given element a number of times.\n"
    "\n"
    " ```gleam\n"
    " repeat(\"hi\", times: 3)\n"
    " // --> from_list([\"hi\", \"hi\", \"hi\"])\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec repeat(HUE, integer()) -> array(HUE).
repeat(Item, Times) ->
    initialise(Times, fun(_) -> Item end).

-file("src/iv.gleam", 394).
?DOC(
    " Creates a list of ints ranging from a given start and finish.\n"
    "\n"
    " ```gleam\n"
    " range(1, 3)\n"
    " // --> from_list([1, 2, 3])\n"
    "\n"
    " range(10, 1)\n"
    " // --> from_list([10, 9, 8, 7, 6, 5, 4, 3, 2, 1])\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec range(integer(), integer()) -> array(integer()).
range(Start, Stop) ->
    case Start =< Stop of
        true ->
            initialise((Stop - Start) + 1, fun(X) -> X + Start end);

        false ->
            initialise((Start - Stop) + 1, fun(X@1) -> Start - X@1 end)
    end.

-file("src/iv.gleam", 446).
?DOC(
    " Check whether or not an array is empty.\n"
    "\n"
    " ```gleam\n"
    " is_empty(from_list([]))\n"
    "  // --> True\n"
    "\n"
    " is_empty(from_list([1, 2, 3]))\n"
    " // --> False\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec is_empty(array(any())) -> boolean().
is_empty(Array) ->
    case Array of
        empty ->
            true;

        {array, _, _} ->
            false
    end.

-file("src/iv.gleam", 468).
?DOC(
    " Returns the number of items in the array.\n"
    "\n"
    " ```gleam\n"
    " size(from_list([]))\n"
    " // --> 0\n"
    "\n"
    " size(from_list([\"hello\", \"joe\"]))\n"
    " // --> 2\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec size(array(any())) -> integer().
size(Array) ->
    case Array of
        empty ->
            0;

        {array, _, Root} ->
            iv@internal@node:size(Root)
    end.

-file("src/iv.gleam", 491).
?DOC(
    " Returns the number of items in the array.\n"
    "\n"
    " ```gleam\n"
    " length(from_list([]))\n"
    " // --> 0\n"
    "\n"
    " length(from_list([\"hello\", \"joe\"]))\n"
    " // --> 2\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec length(array(any())) -> integer().
length(Array) ->
    size(Array).

-file("src/iv.gleam", 517).
?DOC(
    " Checks whether or not two arrays are equal. Arrays are considered to be\n"
    " equal if they have the same length, and their elements are pairwise equal.\n"
    "\n"
    " **Important:** Always use this function instead of the `==` operator! \\\n"
    " Arrays containing the same elements can have different runtime representations.\n"
    "\n"
    " ```gleam\n"
    " equal(from_list([1, 2, 3]), initialise(3, fn(x) { x + 1 }))\n"
    " // --> True\n"
    "\n"
    " equal(from_list([1, 2, 3]), from_list([1]))\n"
    " // --> False\n"
    "\n"
    " equal(from_list([1, 2, 3]), from_list([1, 2, 4]))\n"
    " // --> False\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec equal(array(HUV), array(HUV)) -> boolean().
equal(A, B) ->
    case size(A) =:= size(B) of
        true ->
            _pipe = gleam@yielder:map2(
                to_yielder(A),
                to_yielder(B),
                fun(A@1, B@1) -> A@1 =:= B@1 end
            ),
            gleam@yielder:all(_pipe, fun(A@2) -> A@2 end);

        false ->
            false
    end.

-file("src/iv.gleam", 674).
?DOC(
    " Get the element at a specific index.\n"
    "\n"
    " Arrays are 0-based, so the first element is at index `0`, the second is at\n"
    " index `1`, the third is at index `2`, and so forth, up to `length - 1`.\n"
    "\n"
    " ```gleam\n"
    " let array = from_list([\"trans\", \"rights\", \"are\", \"human\", \"rights\"])\n"
    "\n"
    " get(from: array, at: 1)\n"
    " // --> Ok(\"rights\")\n"
    "\n"
    " get(from: array, at: 3)\n"
    " // --> Ok(\"human\")\n"
    "\n"
    " get(from: array, at: -1)\n"
    " // --> Error(Nil)\n"
    "\n"
    " get(from: array, at: 5)\n"
    " // --> Error(Nil)\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec get(array(HVM), integer()) -> {ok, HVM} | {error, nil}.
get(Array, Index) ->
    case Array of
        {array, Shift, Root} ->
            case (0 =< Index) andalso (Index < iv@internal@node:size(Root)) of
                true ->
                    {ok, iv@internal@node:get(Root, Shift, Index)};

                false ->
                    {error, nil}
            end;

        empty ->
            {error, nil}
    end.

-file("src/iv.gleam", 621).
?DOC(
    " Get the first element from the start of the array, if there is one.\n"
    "\n"
    " ```gleam\n"
    " first(new())\n"
    " // --> Error(Nil)\n"
    "\n"
    " first(from_list([1, 2, 3]))\n"
    " // --> Ok(1)\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec first(array(HVE)) -> {ok, HVE} | {error, nil}.
first(Array) ->
    get(Array, 0).

-file("src/iv.gleam", 644).
?DOC(
    " Get the last element in the array, if there is one.\n"
    "\n"
    " ```gleam\n"
    " last(new())\n"
    " // --> Error(Nil)\n"
    "\n"
    " last(from_list([1]))\n"
    " // --> Ok(1)\n"
    "\n"
    " last(from_list([1, 2, 3]))\n"
    " // --> Ok(3)\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec last(array(HVI)) -> {ok, HVI} | {error, nil}.
last(Array) ->
    get(Array, size(Array) - 1).

-file("src/iv.gleam", 709).
?DOC(
    " Get the element at a specific index. If the index is negative, get the\n"
    " nth-last element instead.\n"
    "\n"
    " ```gleam\n"
    " let array = from_list([\"trans\", \"rights\", \"are\", \"human\", \"rights\"])\n"
    "\n"
    " at(from: array, at: 1)\n"
    " // --> Ok(\"rights\")\n"
    "\n"
    " at(from: array, at: 3)\n"
    " // --> Ok(\"human\")\n"
    "\n"
    " at(from: array, at: -1)\n"
    " // --> Ok(\"rights\")\n"
    "\n"
    " at(from: array, at: 5)\n"
    " // --> Error(Nil)\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec at(array(HVQ), integer()) -> {ok, HVQ} | {error, nil}.
at(Array, Index) ->
    case Index >= 0 of
        true ->
            get(Array, Index);

        false ->
            get(Array, size(Array) + Index)
    end.

-file("src/iv.gleam", 743).
?DOC(
    " Get the element at a specific index, or a default value if the index is out\n"
    " of range.\n"
    "\n"
    " Arrays are 0-based, so the first element is at index `0`, the second is at\n"
    " index `1`, the third is at index `2`, and so forth, up to `length - 1`.\n"
    "\n"
    " ```gleam\n"
    " let array = from_list([\"trans\", \"rights\", \"are\", \"human\", \"rights\"])\n"
    "\n"
    " get_or_default(from: array, at: 1, or: \"\")\n"
    " // --> \"rights\"\n"
    "\n"
    " get_or_default(from: array, at: 3, or: \"\")\n"
    " // --> \"human\"\n"
    "\n"
    " get_or_default(from: array, at: -1, or: \"\")\n"
    " // --> \"\"\n"
    "\n"
    " get_or_default(from: array, at: 5, or: \"\")\n"
    " // --> \"\"\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec get_or_default(array(HVU), integer(), HVU) -> HVU.
get_or_default(Array, Index, Default) ->
    case Array of
        {array, Shift, Root} ->
            case (0 =< Index) andalso (Index < iv@internal@node:size(Root)) of
                true ->
                    iv@internal@node:get(Root, Shift, Index);

                false ->
                    Default
            end;

        empty ->
            Default
    end.

-file("src/iv.gleam", 807).
?DOC(
    " Find the first element for which the given function returns `Ok(value)`,\n"
    " and return the wrapped value.\n"
    "\n"
    " ```gleam\n"
    " find_map(from_list([[], [2], [3]]), list.first)\n"
    " // --> Ok(2)\n"
    "\n"
    " find_map(from_list([[], []]), list.first)\n"
    " // --> Error(Nil)\n"
    "\n"
    " find_map(new(), first)\n"
    " // --> Error(Nil)\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec find_map(array(HWA), fun((HWA) -> {ok, HWC} | {error, nil})) -> {ok, HWC} |
    {error, nil}.
find_map(Array, Is_desired) ->
    case Array of
        empty ->
            {error, nil};

        {array, _, Root} ->
            iv@internal@node:find_map(Root, Is_desired)
    end.

-file("src/iv.gleam", 777).
?DOC(
    " Find the first element from the start  of the array for which the given\n"
    " function returns `True`, and return it.\n"
    "\n"
    " ```gleam\n"
    " find(from_list([1, 2, 3, 4]), fn(x) { x > 2 })\n"
    " // --> Ok(3)\n"
    "\n"
    " find(from_list([1, 2, 3, 4]), fn(x) { x > 4 })\n"
    " // --> Error(Nil)\n"
    "\n"
    " find(new(), fn(_) { True })\n"
    " // --> Error(Nil)\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec find(array(HVW), fun((HVW) -> boolean())) -> {ok, HVW} | {error, nil}.
find(Array, Is_desired) ->
    find_map(Array, fun(Item) -> case Is_desired(Item) of
                true ->
                    {ok, Item};

                false ->
                    {error, nil}
            end end).

-file("src/iv.gleam", 548).
?DOC(
    " Check if a function returns `True` for at least one of the elements\n"
    " in the array.\n"
    "\n"
    " ```gleam\n"
    " any(new(), int.is_even)\n"
    " // --> False\n"
    "\n"
    " any(from_list([1, 3, 5]), int.is_even)\n"
    " // --> False\n"
    "\n"
    " any(from_list([1, 2, 3]), int.is_even)\n"
    " // --> True\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec any(array(HUY), fun((HUY) -> boolean())) -> boolean().
any(Array, Predicate) ->
    case find(Array, Predicate) of
        {ok, _} ->
            true;

        {error, _} ->
            false
    end.

-file("src/iv.gleam", 576).
?DOC(
    " Check if a fuction returns `True` for every element in the array.\n"
    "\n"
    " ```gleam\n"
    " all(new(), int.is_even)\n"
    "  // --> True\n"
    "\n"
    " all(from_list([1, 2, 3]), int.is_even)\n"
    " // --> False\n"
    "\n"
    " all(from_list([2, 4, 6]), int.is_even)\n"
    " // --> True\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec all(array(HVA), fun((HVA) -> boolean())) -> boolean().
all(Array, Predicate) ->
    not any(Array, fun(Item) -> not Predicate(Item) end).

-file("src/iv.gleam", 601).
?DOC(
    " Linearly search through the array to check if it contains an item.\n"
    "\n"
    " ```gleam\n"
    " contains(in: new(), any: 0)\n"
    " // --> False\n"
    "\n"
    " contains(in: from_list([1, 2, 3]), any: 2)\n"
    " // --> True\n"
    "\n"
    " contains(in: from_list([1, 2, 3]), any: 5)\n"
    " // --> False\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec contains(array(HVC), HVC) -> boolean().
contains(Array, Item) ->
    any(Array, fun(Other) -> Other =:= Item end).

-file("src/iv.gleam", 850).
?DOC(
    " Return the index of the first element in the array for which the given\n"
    " function returns `True`, or `Error(Nil)` if no such element can be found.\n"
    "\n"
    " ```gleam\n"
    " find_index(from_list([4, 5, 6, 5]), fn(x) { x > 5 })\n"
    " // --> Ok(2)\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec find_index(array(HWL), fun((HWL) -> boolean())) -> {ok, integer()} |
    {error, nil}.
find_index(Array, Is_desired) ->
    case Array of
        empty ->
            {error, nil};

        {array, Shift, Root} ->
            iv@internal@node:find_index(Shift, 0, Root, Is_desired)
    end.

-file("src/iv.gleam", 833).
?DOC(
    " Return the index of the first occurrence of the given element in the array,\n"
    " or `Error(Nil)` if the array doesn't contain the element.\n"
    "\n"
    " ```gleam\n"
    " index_of(from_list([4, 5, 6, 5]), of: 5)\n"
    " // --> Ok(1)\n"
    "\n"
    " index_of(from_list([4, 5, 6, 5]), of: 1)\n"
    " // --> Error(Nil)\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec index_of(array(HWH), HWH) -> {ok, integer()} | {error, nil}.
index_of(Array, Item) ->
    find_index(Array, fun(Other) -> Other =:= Item end).

-file("src/iv.gleam", 893).
?DOC(
    " Return the index of the last element in the array for which the given\n"
    " function returns `True`, or `Error(Nil)` if no such element can be found.\n"
    "\n"
    " ```gleam\n"
    " find_last_index(from_list([4, 5, 6, 7]), fn(x) { x > 5 })\n"
    " // --> Ok(3)\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec find_last_index(array(HWT), fun((HWT) -> boolean())) -> {ok, integer()} |
    {error, nil}.
find_last_index(Array, Is_desired) ->
    case Array of
        empty ->
            {error, nil};

        {array, Shift, Root} ->
            iv@internal@node:find_last_index(Shift, 0, Root, Is_desired)
    end.

-file("src/iv.gleam", 876).
?DOC(
    " Return the index of the last occurrence of the given element in the array,\n"
    " or `Error(Nil)` if the array doesn't contain the element.\n"
    "\n"
    " ```gleam\n"
    " last_index_of(from_list([4, 5, 6, 5]), of: 5)\n"
    " // --> Ok(3)\n"
    "\n"
    " last_index_of(from_list([4, 5, 6, 5]), of: 1)\n"
    " // --> Error(Nil)\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec last_index_of(array(HWP), HWP) -> {ok, integer()} | {error, nil}.
last_index_of(Array, Item) ->
    find_last_index(Array, fun(Other) -> Other =:= Item end).

-file("src/iv.gleam", 977).
?DOC(
    " Update the element at a given index and return a new array, or return\n"
    " `Error(Nil)` if the index cannot be found in the array.\n"
    "\n"
    " This is slightly more efficient than `get`-ing and then `set`-ing the element.\n"
    "\n"
    " ```gleam\n"
    " from_list([1, 2, 3]) |> update(at: 1, with: fn(x) { x * 2 })\n"
    " // --> Ok(from_list([1, 4, 3]))\n"
    "\n"
    " from_list([1, 2, 3]) |> update(at: -1, with: fn(x) { x + 1 })\n"
    " // --> Error(Nil)\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec update(array(HXF), integer(), fun((HXF) -> HXF)) -> {ok, array(HXF)} |
    {error, nil}.
update(Array, Index, Fun) ->
    case Array of
        {array, Shift, Root} ->
            case (0 =< Index) andalso (Index < iv@internal@node:size(Root)) of
                true ->
                    {ok,
                        {array,
                            Shift,
                            iv@internal@node:update(Shift, Root, Index, Fun)}};

                false ->
                    {error, nil}
            end;

        empty ->
            {error, nil}
    end.

-file("src/iv.gleam", 924).
?DOC(
    " Store a new value at a given index and return the new array, or `Error(Nil)`\n"
    " if the index cannot be found in the array.\n"
    "\n"
    " ```gleam\n"
    " from_list([1, 2, 3]) |> set(at: 1, to: 50)\n"
    " // --> Ok(from_list([1, 50, 3]))\n"
    "\n"
    " from_list([1, 2, 3]) |> set(at: -1, to: 50)\n"
    " // --> Error(Nil)\n"
    "\n"
    " from_list([]) |> set(at: 0, to: 1)\n"
    " // --> Error(Nil)\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec set(array(HWX), integer(), HWX) -> {ok, array(HWX)} | {error, nil}.
set(Array, Index, Item) ->
    update(Array, Index, fun(_) -> Item end).

-file("src/iv.gleam", 1010).
?DOC(
    " Update the element at a given index and return a new array, or return the\n"
    " given array unchanged if the index cannot be found in the array.\n"
    "\n"
    " This is more efficient than `get`-ing and then `try_set`-ing the element.\n"
    "\n"
    " ```gleam\n"
    " from_list([1, 2, 3]) |> try_update(at: 1, with: fn(x) { x * 2 })\n"
    " // --> from_list([1, 4, 3])\n"
    "\n"
    " from_list([1, 2, 3]) |> try_update(at: -1, with: fn(x) { x + 1 })\n"
    " // --> from_list([1, 2, 3])\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec try_update(array(HXK), integer(), fun((HXK) -> HXK)) -> array(HXK).
try_update(Array, Index, Fun) ->
    case Array of
        {array, Shift, Root} ->
            case (0 =< Index) andalso (Index < iv@internal@node:size(Root)) of
                true ->
                    {array,
                        Shift,
                        iv@internal@node:update(Shift, Root, Index, Fun)};

                false ->
                    Array
            end;

        empty ->
            Array
    end.

-file("src/iv.gleam", 951).
?DOC(
    " Store a new value at a given index and return the new array, or return the\n"
    " given array unchanged if the index cannot be found.\n"
    "\n"
    " ```gleam\n"
    " from_list([1, 2, 3]) |> try_set(at: 1, to: 50)\n"
    " // --> from_list([1, 50, 3])\n"
    "\n"
    " from_list([1, 2, 3]) |> try_set(at: -1, to: 50)\n"
    " // --> from_list([1, 2, 3])\n"
    "\n"
    " from_list([]) |> try_set(at: 0, to: 1)\n"
    " // --> from_list([])\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec try_set(array(HXC), integer(), HXC) -> array(HXC).
try_set(Array, Index, Item) ->
    try_update(Array, Index, fun(_) -> Item end).

-file("src/iv.gleam", 1402).
?DOC(
    " Remove the element at a given index by swapping it with the last element,\n"
    " then removing the last element. This is more efficient than `try_delete` but\n"
    " does not preserve the order of elements. If the index does not exist, return\n"
    " the array unchanged.\n"
    "\n"
    " This function runs in _O(log n)_ time.\n"
    "\n"
    " ```gleam\n"
    " from_list([1, 2, 3, 4]) |> try_swap_delete(at: 1)\n"
    " // --> from_list([1, 4, 3])\n"
    "\n"
    " from_list([1, 2, 3]) |> try_swap_delete(at: 3)\n"
    " // --> from_list([1, 2, 3])\n"
    "\n"
    " from_list([]) |> try_swap_delete(at: 0)\n"
    " // --> from_list([])\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec try_swap_delete(array(HZL), integer()) -> array(HZL).
try_swap_delete(Array, Index) ->
    case Array of
        {array, Shift, Root} ->
            Size = iv@internal@node:size(Root),
            case (0 =< Index) andalso (Index < Size) of
                true ->
                    case iv@internal@node:split(Shift, Root, Size - 1) of
                        empty_prefix ->
                            empty;

                        {split, Prefix, Prefix_shift, Suffix, Suffix_shift} ->
                            case Index =:= (Size - 1) of
                                true ->
                                    {array, Prefix_shift, Prefix};

                                false ->
                                    Last = iv@internal@node:get(
                                        Suffix,
                                        Suffix_shift,
                                        0
                                    ),
                                    _pipe = Prefix,
                                    _pipe@1 = iv@internal@node:update(
                                        Prefix_shift,
                                        _pipe,
                                        Index,
                                        fun(_) -> Last end
                                    ),
                                    {array, Prefix_shift, _pipe@1}
                            end
                    end;

                false ->
                    Array
            end;

        empty ->
            Array
    end.

-file("src/iv.gleam", 1369).
?DOC(
    " Remove the element at a given index by swapping it with the last element,\n"
    " then removing the last element. This is more efficient than `delete` but\n"
    " does not preserve the order of elements.\n"
    "\n"
    " This function runs in _O(log n)_ time.\n"
    "\n"
    " ```gleam\n"
    " from_list([1, 2, 3, 4]) |> swap_delete(at: 1)\n"
    " // --> Ok(from_list([1, 4, 3]))\n"
    "\n"
    " from_list([1, 2, 3]) |> swap_delete(at: 3)\n"
    " // --> Error(Nil)\n"
    "\n"
    " from_list([]) |> swap_delete(at: 0)\n"
    " // --> Error(Nil)\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec swap_delete(array(HZG), integer()) -> {ok, array(HZG)} | {error, nil}.
swap_delete(Array, Index) ->
    case (0 =< Index) andalso (Index < size(Array)) of
        true ->
            {ok, try_swap_delete(Array, Index)};

        false ->
            {error, nil}
    end.

-file("src/iv.gleam", 1538).
?DOC(
    " Concatenate two arrays.\n"
    "\n"
    " This function runs in _O(log n)_ time.\n"
    "\n"
    " ```gleam\n"
    " concat(from_list([1, 2, 3]), from_list([4, 5, 6]))\n"
    " // --> from_list([1, 2, 3, 4, 5, 6])\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec concat(array(IAE), array(IAE)) -> array(IAE).
concat(Left, Right) ->
    case {Left, Right} of
        {empty, _} ->
            Right;

        {_, empty} ->
            Left;

        {{array, Shift1, Root1}, {array, Shift2, Root2}} ->
            Max_shift = case Shift1 >= Shift2 of
                true ->
                    Shift1;

                false ->
                    Shift2
            end,
            Roots = case iv@internal@node:concat(Root1, Shift1, Root2, Shift2) of
                {one_node, Root} ->
                    iv_ffi:singleton(Root);

                {two_nodes, Full, Partial} ->
                    iv_ffi:pair(Full, Partial)
            end,
            array(Max_shift, Roots)
    end.

-file("src/iv.gleam", 1559).
?DOC(
    " Direct concat tries to insert nodes into free slots without rebalancing.\n"
    " This is efficient for append/prepend operations where one side is dense.\n"
    " Falls back to regular concat when there are no free slots.\n"
).
-spec direct_concat(array(IAI), array(IAI)) -> array(IAI).
direct_concat(Left, Right) ->
    case {Left, Right} of
        {empty, _} ->
            Right;

        {_, empty} ->
            Left;

        {{array, Left_shift, Left@1}, {array, Right_shift, Right@1}} ->
            Shift = case Left_shift > Right_shift of
                true ->
                    Left_shift;

                false ->
                    Right_shift
            end,
            case iv@internal@node:direct_concat(
                Left_shift,
                Left@1,
                Right_shift,
                Right@1
            ) of
                {concatenated, Root} ->
                    {array, Shift, Root};

                {no_free_slot, Left@2, Right@2} ->
                    array(Shift, iv_ffi:pair(Left@2, Right@2))
            end
    end.

-file("src/iv.gleam", 1040).
?DOC(
    " Add an element to the end of an array.\n"
    "\n"
    " ```gleam\n"
    " from_list([\"hello\"]) |> append(\"joe\")\n"
    " // --> from_list([\"hello\", \"joe\"])\n"
    "\n"
    " from_list([1, 2, 3]) |> append(4) |> append(0)\n"
    " // --> from_list([1, 2, 3, 4, 0])\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec append(array(HXN), HXN) -> array(HXN).
append(Array, Item) ->
    direct_concat(Array, wrap(Item)).

-file("src/iv.gleam", 1060).
?DOC(
    " Add all elements in a list to the end of the array.\n"
    "\n"
    " This more efficient than `append`-ing all elements individually.\n"
    "\n"
    " This function runs in _O(n)_ time, only depending on the size of the appended list.\n"
    "\n"
    " ```gleam\n"
    " from_list([1, 2, 3]) |> append_list([4, 0])\n"
    " // --> from_list([1, 2, 3, 4, 0])\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec append_list(array(HXQ), list(HXQ)) -> array(HXQ).
append_list(Array, Items) ->
    direct_concat(Array, from_list(Items)).

-file("src/iv.gleam", 1087).
?DOC(
    " Add all elements in a list to the end of the array, in reverse order.\n"
    "\n"
    " This is more efficient than reversing the list first and then `append`-ing\n"
    " all the elements.\n"
    "\n"
    " This is useful in tail-recursive algorithms to first build-up a intermediary\n"
    " list instead of appending all elements immediately.\n"
    "\n"
    " This function runs in _O(n)_ time, only depending on the size of the appended list.\n"
    "\n"
    " ```gleam\n"
    " from_list([1, 2, 3]) |> append_reverse_list([4, 0])\n"
    " // --> from_list([1, 2, 3, 0, 4])\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec append_reverse_list(array(HXU), list(HXU)) -> array(HXU).
append_reverse_list(Array, Items) ->
    direct_concat(Array, from_reverse_list(Items)).

-file("src/iv.gleam", 1111).
?DOC(
    " Add an element to the start of the array, making it the first element.\n"
    "\n"
    " This function runs in _O(log n)_ time.\n"
    "\n"
    " ```gleam\n"
    " from_list([\"joe\"]) |> prepend(\"hello\")\n"
    " // --> from_list([\"hello\", \"joe\"])\n"
    "\n"
    " from_list([1, 2, 3]) |> prepend(4) |> prepend(0)\n"
    " // --> from_list([0, 4, 1, 2, 3])\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec prepend(array(HXY), HXY) -> array(HXY).
prepend(Array, Item) ->
    direct_concat(wrap(Item), Array).

-file("src/iv.gleam", 1132).
?DOC(
    " Add many elements to the start of the array, in the same order they appear\n"
    " in the list.\n"
    "\n"
    " This is more efficient than inserting all elements individually.\n"
    "\n"
    " This function runs in _O(n)_ time, only depending on the size of the prepended list.\n"
    "\n"
    " ```gleam\n"
    " from_list([1, 2, 3]) |> prepend_list([4, 5, 6])\n"
    " // --> from_list([4, 5, 6, 1, 2, 3])\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec prepend_list(array(HYB), list(HYB)) -> array(HYB).
prepend_list(Array, Items) ->
    direct_concat(from_list(Items), Array).

-file("src/iv.gleam", 1159).
?DOC(
    " Add many elements to the start of the array, in the reverse order they appear\n"
    " in the list.\n"
    "\n"
    " This is more efficient than reversing the list first and then prepending it.\n"
    "\n"
    " This is useful in tail-recursive algorithms to first build-up a intermediary\n"
    " list instead of prepending all elements immediately.\n"
    "\n"
    " This function runs in _O(n)_ time, only depending on the size of the prepended list.\n"
    "\n"
    " ```gleam\n"
    " from_list([1, 2, 3]) |> prepend_list([4, 5, 6])\n"
    " // --> from_list([6, 5, 4, 1, 2, 3])\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec prepend_reverse_list(array(HYF), list(HYF)) -> array(HYF).
prepend_reverse_list(Array, Items) ->
    direct_concat(from_reverse_list(Items), Array).

-file("src/iv.gleam", 1591).
?DOC(
    " Concatenate many array, joining them up to form a single array.\n"
    "\n"
    " This function runs in _O(n)_ time, only depending on the number of arrays.\n"
    "\n"
    " ```gleam\n"
    " concat_list([from_list([1]), new(), from_list([2, 3])])\n"
    " // --> from_list([1, 2, 3])\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec concat_list(list(array(IAM))) -> array(IAM).
concat_list(Arrays) ->
    gleam@list:fold(Arrays, empty, fun concat/2).

-file("src/iv.gleam", 1634).
?DOC(
    " Split an array in two before the given index.\n"
    "\n"
    " If the list is not long enough to have the given index the before list will\n"
    " be the input list, and the after list will be empty.\n"
    "\n"
    " ```gleam\n"
    " split(from_list([6, 7, 8, 9]), at: 0)\n"
    " // --> #(new(), from_list([6, 7, 8, 9]))\n"
    "\n"
    " split(from_list([6, 7, 8, 9]), at: 2)\n"
    " // --> #(from_list([6, 7]), from_list([8, 9]))\n"
    "\n"
    " split(from_list([6, 7, 8, 9]), at: 4)\n"
    " // --> #(from_list([6, 7, 8, 9]), new())\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec split(array(IAU), integer()) -> {array(IAU), array(IAU)}.
split(Array, Index) ->
    case Array of
        empty ->
            {empty, empty};

        _ when Index =< 0 ->
            {empty, Array};

        {array, Shift, Root} ->
            case iv@internal@node:size(Root) of
                Length when Index >= Length ->
                    {Array, empty};

                _ ->
                    case iv@internal@node:split(Shift, Root, Index) of
                        {split, Prefix, Prefix_shift, Suffix, Suffix_shift} ->
                            Prefix@1 = {array, Prefix_shift, Prefix},
                            Suffix@1 = {array, Suffix_shift, Suffix},
                            {Prefix@1, Suffix@1};

                        empty_prefix ->
                            {empty, Array}
                    end
            end
    end.

-file("src/iv.gleam", 1192).
?DOC(
    " Insert an element at an index into the array, moving all existing elements.\n"
    "\n"
    " This function runs in _O(log n)_ time.\n"
    "\n"
    " ```gleam\n"
    " new() |> insert(at: 0, this: \"hi\")\n"
    " // --> Ok(from_list([\"hi\"]))\n"
    "\n"
    " from_list([1, 2, 3]) |> insert(at: 1, this: 50)\n"
    " // --> Ok(from_list([1, 50, 2, 3]))\n"
    "\n"
    " from_list([1, 2, 3]) |> insert(at: 3, this: 4)\n"
    " // --> Ok(from_list([1, 2, 3, 4]))\n"
    "\n"
    " from_list([1, 2, 3]) |> insert(at: 5, this: 100)\n"
    " // --> Error(Nil)\n"
    "\n"
    " from_list([1, 2, 3]) |> insert(at: -1, this: 0)\n"
    " // --> Error(Nil)\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec insert(array(HYJ), integer(), HYJ) -> {ok, array(HYJ)} | {error, nil}.
insert(Array, Index, Item) ->
    case size(Array) of
        Len when (0 =< Index) andalso (Index =< Len) ->
            {Before, After} = split(Array, Index),
            {ok, concat(direct_concat(Before, wrap(Item)), After)};

        _ ->
            {error, nil}
    end.

-file("src/iv.gleam", 1234).
?DOC(
    " Insert an element at an index into the array, moving all existing elements.\n"
    " If the index is less than `0` prepend, and if it's greater than the number\n"
    " of elements in the array append instead.\n"
    "\n"
    " This function runs in _O(log n)_ time.\n"
    "\n"
    " ```gleam\n"
    " new() |> insert_clamped(at: 0, this: \"hi\")\n"
    " // --> from_list([\"hi\"])\n"
    "\n"
    " from_list([1, 2, 3]) |> insert_clamped(at: 1, this: 50)\n"
    " // --> from_list([1, 50, 2, 3])\n"
    "\n"
    " from_list([1, 2, 3]) |> insert_clamped(at: 3, this: 4)\n"
    " // --> from_list([1, 2, 3, 4])\n"
    "\n"
    " from_list([1, 2, 3]) |> insert_clamped(at: 5, this: 100)\n"
    " // --> from_list([1, 2, 3, 100])\n"
    "\n"
    " from_list([1, 2, 3]) |> insert(at: -1, this: 0)\n"
    " // --> from_list([0, 1, 2, 3])\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec insert_clamped(array(HYO), integer(), HYO) -> array(HYO).
insert_clamped(Array, Index, Item) ->
    case size(Array) of
        _ when Index =< 0 ->
            prepend(Array, Item);

        Len when Index >= Len ->
            append(Array, Item);

        _ ->
            {Before, After} = split(Array, Index),
            concat(direct_concat(Before, wrap(Item)), After)
    end.

-file("src/iv.gleam", 1266).
?DOC(
    " Insert all elements in a given list to the array at a specific index,\n"
    " in the same order they appear in the list.\n"
    "\n"
    " This is more efficient than inserting all elements individually.\n"
    "\n"
    " This function runs in _O(n)_ time, only depending on the size of the inserted list.\n"
    "\n"
    " ```gleam\n"
    " from_list([1, 2, 3]) |> insert_list(at: 1, these: [34, 35])\n"
    " // --> Ok(from_list([1, 34, 35, 2, 3]))\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec insert_list(array(HYR), integer(), list(HYR)) -> {ok, array(HYR)} |
    {error, nil}.
insert_list(Array, Index, Items) ->
    case size(Array) of
        Len when (0 =< Index) andalso (Index =< Len) ->
            {Before, After} = split(Array, Index),
            {ok, concat(direct_concat(Before, from_list(Items)), After)};

        _ ->
            {error, nil}
    end.

-file("src/iv.gleam", 1301).
?DOC(
    " Insert elements at an index into the array, moving all existing elements.\n"
    " If the index is less than `0` prepend, and if it's greater than the number\n"
    " of elements in the array append instead.\n"
    "\n"
    " This is more efficient than inserting all elements individually.\n"
    "\n"
    " This function runs in _O(n)_ time, only depending on the size of the inserted list.\n"
    "\n"
    " ```gleam\n"
    " from_list([1, 2, 3]) |> insert_list_clamped(at: 1, these: [34, 35])\n"
    " // --> from_list([1, 34, 35, 2, 3])\n"
    "\n"
    " from_list([1, 2, 3]) |> insert_list_clamped(at: 100, these: [100, 101])\n"
    " // --> from_list([1, 2, 3, 100, 101])\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec insert_list_clamped(array(HYX), integer(), list(HYX)) -> array(HYX).
insert_list_clamped(Array, Index, Items) ->
    case size(Array) of
        _ when Index =< 0 ->
            prepend_list(Array, Items);

        Len when Index >= Len ->
            append_list(Array, Items);

        _ ->
            {Before, After} = split(Array, Index),
            concat(direct_concat(Before, from_list(Items)), After)
    end.

-file("src/iv.gleam", 1506).
?DOC(
    " Replace a slice using a function, returning the new elements.\n"
    "\n"
    " The entire slice has to exist in the array. Otherwise, `Error(Nil)` is returned.\n"
    "\n"
    " This function runs in _O(log n)_ time.\n"
    "\n"
    " ```gleam\n"
    " from_list([1, 2, 3, 4]) |> splice(at: 1, replace: 2, with: fn(slice) {\n"
    "   map(slice, fn(x) { x * 2 })\n"
    " })\n"
    " // --> Ok(from_list([1, 4, 6, 4]))\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec splice(array(HZX), integer(), integer(), fun((array(HZX)) -> array(HZX))) -> {ok,
        array(HZX)} |
    {error, nil}.
splice(Array, Index, Count, Replacer) ->
    case ((0 =< Index) andalso (0 =< Count)) andalso ((Index + Count) =< size(
        Array
    )) of
        true ->
            {Before, After} = split(Array, Index),
            {Replace, After@1} = split(After, Count),
            {ok, concat(direct_concat(Before, Replacer(Replace)), After@1)};

        false ->
            {error, nil}
    end.

-file("src/iv.gleam", 1479).
?DOC(
    " Replace a slice with a different array.\n"
    "\n"
    " The entire slice has to exist in the array. Otherwise, `Error(Nil)` is returned.\n"
    "\n"
    " This function runs in _O(log n)_ time.\n"
    "\n"
    " ```gleam\n"
    " from_list([1, 2, 3, 4]) |> replace(at: 1, replace: 2, with: from_list([7, 8, 9]))\n"
    " // --> Ok(from_list([1, 7, 8, 9, 4]))\n"
    "\n"
    " from_list([1, 2, 3]) |> replace(at: 2, replace: 1, with: from_list([7, 8, 9]))\n"
    " // --> Ok(from_list([1, 2, 7, 8, 9]))\n"
    "\n"
    " from_list([1, 2, 3]) |> replace(at: 2, replace: 2, with: from_list([8, 8, 9]))\n"
    " // --> Error(Nil)\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec replace(array(HZR), integer(), integer(), array(HZR)) -> {ok, array(HZR)} |
    {error, nil}.
replace(Array, Index, Count, Replacements) ->
    splice(Array, Index, Count, fun(_) -> Replacements end).

-file("src/iv.gleam", 1673).
?DOC(
    " Remove up to `n` elements from the start of the array.\n"
    "\n"
    " If the array has less than `n` elements an empty array is returned.\n"
    "\n"
    " This function runs in _O(log n)_ time.\n"
    "\n"
    " ```gleam\n"
    " drop_first(from_list([1, 2, 3, 4]), up_to: 2)\n"
    " // --> from_list([3, 4])\n"
    "\n"
    " drop_first(from_list([1, 2, 3, 4]), up_to: 5)\n"
    " // --> new()\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec drop_first(array(IAY), integer()) -> array(IAY).
drop_first(Array, N) ->
    case Array of
        _ when N =< 0 ->
            Array;

        empty ->
            empty;

        {array, Shift, Root} ->
            case N < iv@internal@node:size(Root) of
                true ->
                    case iv@internal@node:split(Shift, Root, N) of
                        {split, _, _, Root@1, Suffix_shift} ->
                            {array, Suffix_shift, Root@1};

                        empty_prefix ->
                            Array
                    end;

                false ->
                    empty
            end
    end.

-file("src/iv.gleam", 1732).
?DOC(
    " Return up to the first `n` elements from the start of the array.\n"
    "\n"
    " If the array has less than `n` elements, the original array is returned.\n"
    "\n"
    " This function runs in _O(log n)_ time.\n"
    "\n"
    " ```gleam\n"
    " take_first(from_list([6, 7, 8, 9]), up_to: 3)\n"
    " // --> from_list([6, 7, 8])\n"
    "\n"
    " take_first(from_list([6, 7, 8, 9]), up_to: 10)\n"
    " // --> from_list([6, 7, 8, 9])\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec take_first(array(IBE), integer()) -> array(IBE).
take_first(Array, N) ->
    case Array of
        _ when N =< 0 ->
            empty;

        empty ->
            empty;

        {array, Shift, Root} ->
            case N < iv@internal@node:size(Root) of
                true ->
                    case iv@internal@node:split(Shift, Root, N) of
                        {split, Root@1, Prefix_shift, _, _} ->
                            {array, Prefix_shift, Root@1};

                        empty_prefix ->
                            empty
                    end;

                false ->
                    Array
            end
    end.

-file("src/iv.gleam", 1337).
?DOC(
    " Remove the element at a given index, moving all subsequent elements\n"
    " to the left.\n"
    "\n"
    " This function runs in _O(log n)_ time.\n"
    "\n"
    " ```gleam\n"
    " from_list([1, 2, 3]) |> delete(at: 1)\n"
    " // --> Ok(from_list([1, 3]))\n"
    "\n"
    " from_list([1, 2, 3]) |> delete(at: 3)\n"
    " // --> Error(Nil)\n"
    "\n"
    " from_list([]) |> delete(at: 0)\n"
    " // --> Error(Nil)\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec delete(array(HZB), integer()) -> {ok, array(HZB)} | {error, nil}.
delete(Array, Index) ->
    case (0 =< Index) andalso (Index < size(Array)) of
        true ->
            {ok, concat(take_first(Array, Index), drop_first(Array, Index + 1))};

        false ->
            {error, nil}
    end.

-file("src/iv.gleam", 1450).
?DOC(
    " Remove the element at a given index, moving all subsequent elements\n"
    " to the left. If the index does not exist, return the array unchanged.\n"
    "\n"
    " This function runs in _O(log n)_ time.\n"
    "\n"
    " ```gleam\n"
    " from_list([1, 2, 3]) |> try_delete(at: 1)\n"
    " // --> from_list([1, 3])\n"
    "\n"
    " from_list([1, 2, 3]) |> try_delete(at: 3)\n"
    " // --> from_list([1, 2, 3])\n"
    "\n"
    " from_list([]) |> try_delete(at: 0)\n"
    " // --> from_list([])\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec try_delete(array(HZO), integer()) -> array(HZO).
try_delete(Array, Index) ->
    case (0 =< Index) andalso (Index < size(Array)) of
        true ->
            concat(take_first(Array, Index), drop_first(Array, Index + 1));

        false ->
            Array
    end.

-file("src/iv.gleam", 1709).
?DOC(
    " Remove up to `n` elements from the end of the array.\n"
    "\n"
    " If the array has less than `n` elements an empty array is returned.\n"
    "\n"
    " This function runs in _O(log n)_ time.\n"
    "\n"
    " ```gleam\n"
    " drop_last(from_list([1, 2, 3, 4]), up_to: 2)\n"
    " // --> from_list([1, 2])\n"
    "\n"
    " drop_last(from_list([1, 2, 3, 4]), up_to: 5)\n"
    " // --> new()\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec drop_last(array(IBB), integer()) -> array(IBB).
drop_last(Array, N) ->
    take_first(Array, size(Array) - N).

-file("src/iv.gleam", 1768).
?DOC(
    " Return up `n` elements from the end of the array.\n"
    "\n"
    " If the array has less than `n` elements, the original array is returned.\n"
    "\n"
    " This function runs in _O(log n)_ time.\n"
    "\n"
    " ```gleam\n"
    " take_last(from_list([6, 7, 8, 9]), up_to: 3)\n"
    " // --> from_list([7, 8, 9])\n"
    "\n"
    " take_last(from_list([6, 7, 8, 9]), up_to: 10)\n"
    " // --> from_list([6, 7, 8, 9])\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec take_last(array(IBH), integer()) -> array(IBH).
take_last(Array, N) ->
    drop_first(Array, size(Array) - N).

-file("src/iv.gleam", 1788).
-spec sized_chunk_loop(array(IBO), integer(), list(array(IBO))) -> array(array(IBO)).
sized_chunk_loop(Array, Count, Chunks) ->
    Size = size(Array),
    case Size =< Count of
        true ->
            case Size of
                0 ->
                    from_reverse_list(Chunks);

                _ ->
                    from_reverse_list([Array | Chunks])
            end;

        false ->
            {Chunk, Rest} = split(Array, Count),
            sized_chunk_loop(Rest, Count, [Chunk | Chunks])
    end.

-file("src/iv.gleam", 1784).
?DOC(
    " Returns an array of chunks containing `count` elements each.\n"
    "\n"
    " If the last chunk does not have count elements, it is instead a partial\n"
    " chunk, with less than count elements.\n"
    "\n"
    " For any count less than 1 this function behaves as if it was set to 1.\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec sized_chunk(array(IBK), integer()) -> array(array(IBK)).
sized_chunk(Array, Count) ->
    sized_chunk_loop(Array, gleam@int:min(1, Count), []).

-file("src/iv.gleam", 1823).
-spec split_n_loop(array(ITT), integer(), integer(), list(array(ITT))) -> array(array(ITT)).
split_n_loop(Array, Count, Rest, Chunks) ->
    Size = size(Array),
    case Size =< Count of
        true ->
            case Size of
                0 ->
                    from_reverse_list(Chunks);

                _ ->
                    from_reverse_list([Array | Chunks])
            end;

        false ->
            {Chunk, Array@1} = case Rest > 0 of
                false ->
                    split(Array, Count);

                true ->
                    split(Array, Count + 1)
            end,
            split_n_loop(Array@1, Count, Rest - 1, [Chunk | Chunks])
    end.

-file("src/iv.gleam", 1819).
?DOC(
    " Returns an array distributing its elements evenly into `n` chunks.\n"
    "\n"
    " If there are less than `n` elements in the array, less chunks may be\n"
    " returned.\n"
    "\n"
    " For any count less than 1 this function behaves as if it was set to 1.\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec split_n(array(IBU), integer()) -> array(array(IBU)).
split_n(Array, N_chunks) ->
    split_n_loop(Array, case N_chunks of
            0 -> 0;
            Gleam@denominator -> size(Array) div Gleam@denominator
        end, case N_chunks of
            0 -> 0;
            Gleam@denominator@1 -> size(Array) rem Gleam@denominator@1
        end, []).

-file("src/iv.gleam", 1858).
?DOC(
    " Return the array without the first element. If the array is empty,\n"
    " `Error(Nil)` is returned.\n"
    "\n"
    " ```gleam\n"
    " rest(from_list([1, 2, 3]))\n"
    " // --> Ok(from_list([2, 3]))\n"
    "\n"
    " rest(new())\n"
    " // --> Error(Nil)\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec rest(array(ICD)) -> {ok, array(ICD)} | {error, nil}.
rest(Array) ->
    case Array of
        empty ->
            {error, nil};

        {array, _, _} ->
            {ok, drop_first(Array, 1)}
    end.

-file("src/iv.gleam", 1882).
?DOC(
    " Return the array without the last element. If the array is empty,\n"
    " `Error(Nil)` is returned.\n"
    "\n"
    " ```gleam\n"
    " leading(from_list([1, 2, 3]))\n"
    " // --> Ok(from_list([1, 2]))\n"
    "\n"
    " leading(new())\n"
    " // --> Error(Nil)\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec leading(array(ICI)) -> {ok, array(ICI)} | {error, nil}.
leading(Array) ->
    case Array of
        empty ->
            {error, nil};

        {array, _, _} ->
            {ok, drop_last(Array, 1)}
    end.

-file("src/iv.gleam", 1950).
?DOC(
    " Extract a sub-slice from the array.\n"
    "\n"
    " This function runs in _O(log n)_ time.\n"
    "\n"
    " ```gleam\n"
    " let array = from_list([6, 7, 8, 9])\n"
    "\n"
    " slice_clamped(from: array, start: 1, size: 2)\n"
    " // --> from_list([7, 8])\n"
    "\n"
    " slice_clamped(from: array, start: 2, size: 3)\n"
    " // --> from_list([8, 9])\n"
    "\n"
    " slice_clamped(from: array, start: 5, size: 0)\n"
    " // --> from_list([])\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec slice_clamped(array(ICS), integer(), integer()) -> array(ICS).
slice_clamped(Array, Start, Size) ->
    {_, Array@1} = split(Array, Start),
    {Array@2, _} = split(Array@1, Size),
    Array@2.

-file("src/iv.gleam", 1912).
?DOC(
    " Extract a sub-slice from the array. If the start is not part of the\n"
    " array or if the array does not contain enough elements, `Error(Nil)` is returned.\n"
    "\n"
    " This function runs in _O(log n)_ time.\n"
    "\n"
    " ```gleam\n"
    " let array = from_list([6, 7, 8, 9])\n"
    "\n"
    " slice(from: array, start: 1, size: 2)\n"
    " // --> Ok(from_list([7, 8]))\n"
    "\n"
    " slice(from: array, start: 2, size: 3)\n"
    " // --> Error(Nil)\n"
    "\n"
    " slice(from: array, start: 5, size: 0)\n"
    " // --> Error(Nil)\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec slice(array(ICN), integer(), integer()) -> {ok, array(ICN)} | {error, nil}.
slice(Array, Start, Size) ->
    case Array of
        empty when Size =:= 0 ->
            {ok, empty};

        empty ->
            {error, nil};

        {array, _, Root} ->
            case (0 =< Start) andalso ((Start + Size) =< iv@internal@node:size(
                Root
            )) of
                true ->
                    {ok, slice_clamped(Array, Start, Size)};

                false ->
                    {error, nil}
            end
    end.

-file("src/iv.gleam", 2004).
?DOC(
    " Return a copy of the array, where each element is replaced by the result\n"
    " of a function.\n"
    "\n"
    " ```gleam\n"
    " map(from_list([6, 7, 8]), fn(x) { x * 2 })\n"
    " // --> from_list([12, 14, 16])\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec map(array(ICY), fun((ICY) -> IDA)) -> array(IDA).
map(Array, Fun) ->
    case Array of
        empty ->
            empty;

        {array, Shift, Root} ->
            {array, Shift, iv@internal@node:map(Root, Fun)}
    end.

-file("src/iv.gleam", 2024).
?DOC(
    " Return a copy of the array, where each element is replaced by the result\n"
    " of applying a function to the index and the element at that index.\n"
    "\n"
    " ```gleam\n"
    " index_map(from_list([6, 7, 8]), fn(x, i) { #(i, x) })\n"
    " // --> from_list([#(0, 6), #(1, 7), #(2, 8)])\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec index_map(array(IDC), fun((IDC, integer()) -> IDE)) -> array(IDE).
index_map(Array, Fun) ->
    case Array of
        empty ->
            empty;

        {array, Shift, Root} ->
            {array, Shift, iv@internal@node:index_map(Shift, 0, Root, Fun)}
    end.

-file("src/iv.gleam", 2051).
?DOC(
    " Return a copy of the array, where each element is replaced by the `Ok(_)`\n"
    " result of applying a function to each element.\n"
    "\n"
    " If the fuction returns `Error(_)` for any of the elements, that error is\n"
    " immediately returned instead.\n"
    "\n"
    " ```gleam\n"
    " try_map(from_list([[1], [2, 3]]), list.first)\n"
    " // --> Ok(from_list([1, 2]))\n"
    "\n"
    " try_map(from_list([[1], [], [2, 3]]), list.first)\n"
    " // --> Error(Nil)\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec try_map(array(IDG), fun((IDG) -> {ok, IDI} | {error, IDJ})) -> {ok,
        array(IDI)} |
    {error, IDJ}.
try_map(Array, Fun) ->
    case Array of
        empty ->
            {ok, empty};

        {array, Shift, Root} ->
            case iv@internal@node:try_map(Root, Fun) of
                {ok, Root@1} ->
                    {ok, {array, Shift, Root@1}};

                {error, Error} ->
                    {error, Error}
            end
    end.

-file("src/iv.gleam", 2164).
?DOC(
    " Combine 2 arrays into a single array using the given function.\n"
    "\n"
    " If one array is longer than the other, the extra elements are dropped from\n"
    " the end.\n"
    "\n"
    " ```gleam\n"
    " map2(from_list([1, 2, 3]), from_list([4, 5, 6]), int.add)\n"
    " // --> from_list([5, 7, 9])\n"
    "\n"
    " map2(from_list([1, 2]), from_list([\"a\", \"b\", \"c\"]), fn(a, b) { #(a, b) })\n"
    " // --> from_list([#(1, \"a\"), #(2, \"b\")])\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec map2(array(IEE), array(IEG), fun((IEE, IEG) -> IEI)) -> array(IEI).
map2(A, B, Fun) ->
    _pipe = gleam@yielder:map2(to_yielder(A), to_yielder(B), Fun),
    from_yielder(_pipe).

-file("src/iv.gleam", 2187).
?DOC(
    " Combine 2 arrays into a single array of 2-element tuples.\n"
    "\n"
    " If one array is longer than the other, the extra elements are dropped from\n"
    " the end.\n"
    "\n"
    " ```gleam\n"
    " zip(from_list([1, 2, 3]), from_list([\"a\", \"b\", \"c\"]))\n"
    " // --> from_list([#(1, \"a\"), #(2, \"b\"), #(3, \"c\")])\n"
    "\n"
    " zip(from_list([]), from_list([\"a\", \"b\", \"c\"]))\n"
    " // --> new()\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec zip(array(IEK), array(IEM)) -> array({IEK, IEM}).
zip(A, B) ->
    map2(A, B, fun(A@1, B@1) -> {A@1, B@1} end).

-file("src/iv.gleam", 2279).
?DOC(
    " Build up a new value by looping through each of the elements from the start\n"
    " to the end.\n"
    "\n"
    " ```gleam\n"
    " fold(from_list([6, 7, 8]), from: 0, with: int.add)\n"
    " // --> 21\n"
    "\n"
    " fold(from_list([6, 7, 8]), from: [], with: list.prepend)\n"
    " // --> [8, 7, 6]\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec fold(array(IFD), IFF, fun((IFF, IFD) -> IFF)) -> IFF.
fold(Array, State, Fun) ->
    case Array of
        empty ->
            State;

        {array, _, Root} ->
            iv@internal@node:fold(Root, State, Fun)
    end.

-file("src/iv.gleam", 352).
?DOC(
    " Convert a string array to a single string by joining the items together\n"
    " using the given separator.\n"
    "\n"
    " ```gleam\n"
    " from_list([\"trans\", \"rights\", \"are\", \"human\", \"rights\"])\n"
    " |> join(with: \" \")\n"
    "  // --> \"trans rights are human rights\"\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec join(array(binary()), binary()) -> binary().
join(Strings, Separator) ->
    case get(Strings, 0) of
        {error, _} ->
            <<""/utf8>>;

        {ok, First} ->
            fold(
                drop_first(Strings, 1),
                First,
                fun(Result, String) ->
                    <<<<Result/binary, Separator/binary>>/binary,
                        String/binary>>
                end
            )
    end.

-file("src/iv.gleam", 1609).
?DOC(
    " Concatenate many arrays, joining them up to form a single array.\n"
    "\n"
    " This function runs in _O(n)_ time, only depending on the number of arrays.\n"
    "\n"
    " ```gleam\n"
    " flatten(from_list([from_list([1]), new(), from_list([2, 3])]))\n"
    " // --> from_list([1, 2, 3])\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec flatten(array(array(IAQ))) -> array(IAQ).
flatten(Arrays) ->
    fold(Arrays, empty, fun concat/2).

-file("src/iv.gleam", 2077).
?DOC(
    " Map every element in the array to a new array, and then flatten them.\n"
    "\n"
    " ```gleam\n"
    " flat_map(from_list([2, 4, 6]), fn(x) { from_list([x, x + 1]) })\n"
    " // --> from_list([2, 3, 4, 5, 6, 7])\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec flat_map(array(IDP), fun((IDP) -> array(IDR))) -> array(IDR).
flat_map(Array, Fun) ->
    fold(Array, empty, fun(Result, Item) -> concat(Result, Fun(Item)) end).

-file("src/iv.gleam", 2098).
?DOC(
    " Build a new array containing only the elements for which the given function\n"
    " returns `True`.\n"
    "\n"
    " ```gleam\n"
    " filter(from_list([1, 2, 3, 4]), int.is_even)\n"
    " // --> from_list([2, 4])\n"
    "\n"
    " filter(from_list([1, 2, 3, 4]), fn(x) { x > 6 })\n"
    " // --> new()\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec filter(array(IDU), fun((IDU) -> boolean())) -> array(IDU).
filter(Items, Predicate) ->
    Result = iv@internal@builder:build(
        begin
            fold(
                Items,
                iv@internal@builder:new(),
                fun(Builder, Item) -> case Predicate(Item) of
                        true ->
                            iv@internal@builder:push(Builder, Item);

                        false ->
                            Builder
                    end end
            )
        end
    ),
    case Result of
        {ok, {Shift, Nodes}} ->
            array(Shift, Nodes);

        {error, _} ->
            empty
    end.

-file("src/iv.gleam", 2130).
?DOC(
    " Build a new array containing only the values for which the given function\n"
    " returns `Ok(_)`.\n"
    "\n"
    " ```gleam\n"
    " filter_map(from_list([[], [1], [2, 3]]), list.first)\n"
    " // --> from_list([1, 2])\n"
    "\n"
    " filter_map(from_list([1, 2, 3]), Error)\n"
    " // --> new()\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec filter_map(array(IDX), fun((IDX) -> {ok, IDZ} | {error, any()})) -> array(IDZ).
filter_map(Items, Fun) ->
    Result = iv@internal@builder:build(
        begin
            fold(
                Items,
                iv@internal@builder:new(),
                fun(Builder, Item) -> case Fun(Item) of
                        {ok, New_item} ->
                            iv@internal@builder:push(Builder, New_item);

                        {error, _} ->
                            Builder
                    end end
            )
        end
    ),
    case Result of
        {ok, {Shift, Nodes}} ->
            array(Shift, Nodes);

        {error, _} ->
            empty
    end.

-file("src/iv.gleam", 2212).
?DOC(
    " Loop through the elements from the start to the end, calling a function\n"
    " and discarding the result.\n"
    "\n"
    " Useful for performing some side-effects for every element.\n"
    "\n"
    " ```gleam\n"
    " use item <- each(from_list([1, 2, 3]))\n"
    " io.println(int.to_string(item))\n"
    " // 1\n"
    " // 2\n"
    " // 3\n"
    " // --> Nil\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec each(array(IEP), fun((IEP) -> any())) -> nil.
each(Array, Something) ->
    fold(
        Array,
        nil,
        fun(_use0, Item) ->
            nil = _use0,
            Something(Item),
            nil
        end
    ).

-file("src/iv.gleam", 2297).
?DOC(
    " Like `fold`, but also passes the index of the current element.\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec index_fold(array(IFG), IFI, fun((IFI, IFG, integer()) -> IFI)) -> IFI.
index_fold(Array, State, Fun) ->
    case Array of
        empty ->
            State;

        {array, Shift, Root} ->
            iv@internal@node:index_fold(Shift, 0, Root, State, Fun)
    end.

-file("src/iv.gleam", 2324).
?DOC(
    " Build up a new value by looping in reverse from the end to the start through\n"
    " the array.\n"
    "\n"
    " ```gleam\n"
    " fold_right(from_list([6, 7, 8]), from: 0, with: int.add)\n"
    " // --> 21\n"
    "\n"
    " fold_right(from_list([6, 7, 8]), from: [], with: list.prepend)\n"
    " // --> [6, 7, 8]\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec fold_right(array(IFJ), IFL, fun((IFL, IFJ) -> IFL)) -> IFL.
fold_right(Array, State, Fun) ->
    case Array of
        empty ->
            State;

        {array, _, Root} ->
            iv@internal@node:fold_right(Root, State, Fun)
    end.

-file("src/iv.gleam", 308).
?DOC(
    " Convert an array to a standard Gleam list.\n"
    "\n"
    " ```gleam\n"
    " to_list(initialise(5, fn(x) { x + 1 }))\n"
    " // --> [1, 2, 3, 4, 5]\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec to_list(array(HTX)) -> list(HTX).
to_list(Array) ->
    fold_right(Array, [], fun gleam@list:prepend/2).

-file("src/iv.gleam", 1980).
?DOC(
    " Create a new array containing the same elements, but in the opposite order.\n"
    "\n"
    " ```gleam\n"
    " reverse(from_list([6, 7, 8]))\n"
    " // --> from_list([8, 7, 6])\n"
    "\n"
    " reverse(from_list([1]))\n"
    " // --> from_list([1])\n"
    "\n"
    " reverse(new())\n"
    " // --> new()\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec reverse(array(ICV)) -> array(ICV).
reverse(Items) ->
    case begin
        _pipe = Items,
        _pipe@1 = fold_right(
            _pipe,
            iv@internal@builder:new(),
            fun iv@internal@builder:push/2
        ),
        iv@internal@builder:build(_pipe@1)
    end of
        {ok, {Shift, Nodes}} ->
            array(Shift, Nodes);

        {error, _} ->
            empty
    end.

-file("src/iv.gleam", 2257).
?DOC(
    " Loop through the elements in reverse order from the end to the start,\n"
    " calling a function on each element and discarding the result.\n"
    "\n"
    " Useful for performing some side-effects for every element.\n"
    "\n"
    " ```gleam\n"
    " use item <- each(from_list([1, 2, 3]))\n"
    " io.println(int.to_string(item))\n"
    " // 3\n"
    " // 2\n"
    " // 1\n"
    " // --> Nil\n"
    " ```\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec each_right(array(IFA), fun((IFA) -> any())) -> nil.
each_right(Array, Something) ->
    fold_right(
        Array,
        nil,
        fun(_use0, Item) ->
            nil = _use0,
            Something(Item),
            nil
        end
    ).

-file("src/iv.gleam", 2342).
?DOC(
    " Like `fold`, but pass the current index to the accumulator function.\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec index_fold_right(array(IFN), IFP, fun((IFP, IFN, integer()) -> IFP)) -> IFP.
index_fold_right(Array, State, Fun) ->
    case Array of
        empty ->
            State;

        {array, Shift, Root} ->
            iv@internal@node:index_fold_right(Shift, 0, Root, State, Fun)
    end.

-file("src/iv.gleam", 2364).
?DOC(
    " A variant of `fold` that builds up a new value using a function that can\n"
    " fail.\n"
    "\n"
    " If the function returns `Error(_)`, iteration is stopped and the error is\n"
    " returned immediately. Otherwise, the final built-up value is returned.\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec try_fold(array(IFR), IFT, fun((IFT, IFR) -> {ok, IFT} | {error, IFU})) -> {ok,
        IFT} |
    {error, IFU}.
try_fold(Array, State, Fun) ->
    case Array of
        empty ->
            {ok, State};

        {array, _, Root} ->
            iv@internal@node:try_fold(Root, State, Fun)
    end.

-file("src/iv.gleam", 2227).
?DOC(
    " Loop through the elements from the start to the end, calling a\n"
    " result-returning function for all of them. As soon as the function returns\n"
    " `Error(_)`, iteration is stopped and the error is returned.\n"
    "\n"
    " <div style=\"text-align: right;\">\n"
    "     <a href=\"#\">\n"
    "         <small>Back to top ↑</small>\n"
    "     </a>\n"
    " </div>\n"
).
-spec try_each(array(IES), fun((IES) -> {ok, any()} | {error, IEV})) -> {ok,
        nil} |
    {error, IEV}.
try_each(Array, Something) ->
    try_fold(
        Array,
        nil,
        fun(_use0, Item) ->
            nil = _use0,
            case Something(Item) of
                {ok, _} ->
                    {ok, nil};

                {error, Error} ->
                    {error, Error}
            end
        end
    ).
