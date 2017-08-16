use Data::Dump::Tree ;
use Data::Dump::Tree::Ddt ; # for ddt_remote

my $s = [1, [1, [1..2]]] ;

ddt :title<:curses>, $s, :curses ;



