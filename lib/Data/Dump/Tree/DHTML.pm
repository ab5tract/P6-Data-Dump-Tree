
use Data::Dump::Tree ;
use Data::Dump::Tree::DescribeBaseObjects ;

role DDTR::DHTML
{
my $a2h = ( [ "'", '"', '&', '<', '>' ] =>  [ '&apos;', '&quot;', '&amp;', '&lt;', '&gt;' ]) ;
my $class_bag = (^10_000).BagHash ;

method dump_dhtml($s, *%options) is export { say $.get_dhtml_dump($s, |%options) }

method get_dhtml_dump($s, *%options) is export 
{
%options<wrap_data> //= %() ;
my %s := %options<wrap_data> ;

%s<uuid>                 = 0 ;
%s<DHTML>              //= '' ;
%s<class>              //= 'ddt_' ~ $class_bag.grab(1) ;
%s<style_none>         //= 0 ;
%s<collapsed>          //= False ;
%s<button_collapse>    //= True ;
%s<collapse_button_id> //= "%s<class>_button_1" ;
%s<collapse_ids>       //= () ;
%s<button_search>      //= True ;
%s<search_button_id>   //= "%s<class>_button_2" ;

%s<style> //= qq:to/STYLE/ ;
<style type='text/css'>
a\{text-decoration: none; white-space: pre; }
.%s<class> li \{list-style-type:none ; margin:0 ; padding:0 ; line-height: 1em ; }
.%s<class> ul \{margin:0 ; padding:0 ;}
ul.%s<class> \{padding:0 ; font-family:monospace ; white-space:nowrap ;}
</style>
STYLE

%s<style> = '' if %s<style_none> ;

qq:to/DHTML/ ;
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE html 
     PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"
     "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
>

<html>
<!-- Generated by Perl 6 Data::Dumper::Tree::DHTML -->

<head> <title>Data Dump</title> </head>
<body>
%s<style>

<div>
{
(%s<button_collapse>
	?? %s<collapsed> 
		?? "   <input type='button' id='%s<collapse_button_id>' onclick='expand_collapse_%s<class>\(true)' value='Expand'/>\n"
		!! "   <input type='button' id='%s<collapse_button_id>' onclick='expand_collapse_%s<class>\(true)' value='Collapse'/>\n"
	!! '')

~ # append

(%s<button_search>
	?? "   <input type='button' id='%s<search_button_id>' onclick='search_{%s<class>}()' value='Search'/>\n" 
	!! '')
}	
</div>

<ul  class='{%s<class>}'>
{ $.wrap_dump($s, |%options) }
</ul>

{ get_javascript :%s }

</body>
</html>
DHTML
}

method wrap_dump($s, *%options)
{
%options<width> = $.width // 1000 ;

my ($r, $wrap_data) = $.get_dump_lines(
		$s,
		:!color,
		:wrap_data(%options<wrap_data>),
		:wrap_header(&header_wrap),
		:wrap_footer(&footer_wrap),
		|%options,
		does => ( DDTR::UnicodeGlyphs,), #todo: add to does if it exists instead
		);

$wrap_data<DHTML> 
}

my sub header_wrap(
	\wd,
	($glyph, $continuation_glyph, $multi_line_glyph),
	($kvf, @ks, @vs, @fs),
	$s,
	($depth, $path, $filter_glyph, @renderings),
	($k, $b, $v, $f, $final, $want_address),
	) 
{
my ($pad, $pad2)  = ( '   ' xx $depth + 1, '   ' xx $depth + 2) ; 
my ($class, $uuid) = (wd<class>, wd<class> ~ '_' ~ wd<uuid>) ;
my ($a_uuid, $c_uuid) = ("a_$uuid", "c_$uuid") ;

if $kvf.defined
	{
	my $span = $glyph ;
	$span ~= $final
			?? "<font color='black'>" ~ "$k$b".trans($a2h) ~ '</font> '
			!! "$k$b".trans($a2h) ;

	$span ~= '<font color="black">' ~ ($v//'').trans($a2h) ~ '</font> ' 
		~ '<font color=#bbbbbb>' ~ ($f//'').trans($a2h) ~ '</font>' ;

	if $final
		{
		wd<DHTML> ~= "$pad\<li><a id='$a_uuid' data-final=1>$span\</a>\n" ;
		wd<DHTML> ~= "$pad2\<ul class='$class' id='$c_uuid' style = 'display:none'></ul>\n"
		}
	else
		{
		wd<DHTML> ~= "$pad\<li><a id='$a_uuid' href='javascript:void(0);' onclick='toggleList_$class\(\"$c_uuid\", \"$a_uuid\")'>$span\</a>\n" ;

		wd<DHTML> ~= wd<collapsed> 
				?? "$pad2\<ul  class='$class' id='$c_uuid' style = 'display:none'>\n"
				!! "$pad2\<ul  class='$class' id='$c_uuid' style = 'display:block'>\n" ;
		}
	}
else
	{
	wd<DHTML> ~= "$pad\<li><a id='$a_uuid'" ;

	wd<DHTML> ~= $final
		?? " data-final=1>"
		!! " href='javascript:void(0);' onclick='toggleList_$class\(\"$c_uuid\", \"$a_uuid\")'>" ;

	if @ks	{ wd<DHTML> ~= $glyph ~ @ks[0].trans($a2h) ~ '<br>' ; }
	if @ks > 1
		{
		for @ks[1..*-1] -> $ks
			{
			wd<DHTML> ~= $continuation_glyph ~ $ks.trans($a2h) ~ '<br>' ;
			} ; 
		}
			
	for @vs -> $vs
		{
		wd<DHTML> ~= $final
			?? "<font color='black'>$continuation_glyph$multi_line_glyph"
			!! "$continuation_glyph$multi_line_glyph\<font color='black'>" ;

		wd<DHTML> ~= $vs.trans($a2h) ~ '</font><br>' ;
		} ; 
	
	for @fs -> $fs
		{
		#todo: next if $.display_info == False ;

		wd<DHTML> ~= $final
			?? "<font color='black'>$continuation_glyph$multi_line_glyph"
			!! "$continuation_glyph$multi_line_glyph" ;

		wd<DHTML> ~= "<font color=#cccccc>" ~ $fs.trans($a2h) ~ '</font><br>' ;
		} ; 

	wd<DHTML> ~= "</a>\n" ;
	
	if $final
		{
		wd<DHTML> ~="$pad2\<ul  class='$class' id='$c_uuid' style = 'display:none'></ul>\n" ;
		}
	else
		{
		wd<DHTML> ~= wd<collapsed> 
			?? "$pad2\<ul  class='$class' id='$c_uuid' style = 'display:none'>\n"
			!! "$pad2\<ul  class='$class' id='$c_uuid' style = 'display:block'\n>" ;
		}
	}

wd<uuid>++ ;
}

my sub footer_wrap(\wd, $s, $final, ($depth, $filter_glyph, @renderings))
{
wd<DHTML> ~= '   ' xx $depth + 2 ~ "</ul>\n" unless $final ;
wd<DHTML> ~= '   ' xx $depth + 1 ~ "</li>\n" ;
}

my sub get_javascript(:%s)
{
my $class = %s<class> ;

my $a_ids = (^%s<uuid>).map({ "'a_{%s<class>}_{$_}'" }).join(', ') ;
my $collapsable_ids = (^%s<uuid>).map({ "'c_{%s<class>}_{$_}'" }).join(', ') ;

my $collapsed = %s<collapsed> ;

qq:to/EOS/ ;
<script type='text/javascript'>

function search_{$class}()
\{
var string_to_search = prompt('DDTR::DHTML Search','');
var regexp = new RegExp(string_to_search, 'i') ;

var i ;
for (i = 0 ; i < a_id_array_{$class}.length; i++)
	\{
	if (document.getElementById) 
		\{
		if(regexp.test(document.getElementById(a_id_array_{$class}[i]).text))
			\{
			show_specific_node_{$class}(document.getElementById(a_id_array_{$class}[i])) ;
			document.getElementById(a_id_array_{$class}[i]).style.color = '' ;
			document.getElementById(a_id_array_{$class}[i]).style.backgroundColor = 'cyan' ;
			break ;
			}
		}
	else if (document.all) 
		\{
		if(regexp.test(document.all[a_id_array_{$class}[0]].text))
			\{
			show_specific_node_{$class}(document.all[a_id_array_{$class}[0]]) ;
			break ;
			}
		}
	else if (document.layers) 
		\{
		if(regexp.test(document.layers[a_id_array_{$class}[0]].text))
			\{
			show_specific_node_{$class}(document.layers[a_id_array_{$class}[0]]) ;
			break ;
			}
		}
	}
}

function show_specific_node_{$class} (node)
\{
collapsed_{$class} = 0; /* hide all */
expand_collapse_{$class}();

do
	\{
	node = node.parentNode;
	
	if (node && node.tagName == 'UL')
		node.style.display = 'block';
		
	} while (node && node.parentNode);
}

var a_id_array_{$class}= new Array
		(
		$a_ids
		) ;

var collapsable_id_array_{$class} = new Array
				(
				$collapsable_ids
				) ;

var collapsed_{$class} = { $collapsed ?? 1 !! 0 } ;

function expand_collapse_{$class}() 
\{
var style ;
if(collapsed_{$class}== 1)
	\{
	collapsed_{$class} = 0 ;
	color = '' ;
	style = "block" ;
	replace_button_text("{%s<collapse_button_id>}", "Collapse") ;
	}
else
	\{
	collapsed_{$class} = 1 ;
	color = 'magenta' ;
	style = "none" ;
	replace_button_text("{%s<collapse_button_id>}", "Expand") ;
	}

var i;
for (i = 0; i < { %s<uuid> } ; i++)
	\{
	if (document.getElementById) 
		\{
		document.getElementById(collapsable_id_array_{$class}\[i]).style.display = style ;
		document.getElementById(a_id_array_{$class}[i]).style.backgroundColor = '' ;

		var element = document.getElementById(a_id_array_{$class}\[i]) ;
		var final =  element.getAttribute('data-final') ;
 		if(! final) \{ element.style.color = color ; }
		}
	else if (document.all) 
		\{
		document.all[collapsable_id_array_{$class}\[i]].style.display = style ;

		var element = document.all[a_id_array_{$class}\[i]] ;
		var final =  element.getAttribute('data-final') ;
		if(! final) \{ element.style.color = color ; }
		}
	else if (document.layers) 
		\{
		document.layers[collapsable_id_array_{$class}\[i]].display = style ;
	
		var element = document.layers[a_id_array_{$class}\[i]] ;
		var final =  element.getAttribute('data-final') ;
		if(! final) \{ element.color = color ; }
		}
	}
}

function replace_button_text(buttonId, text)
\{
if (document.getElementById)
	\{
	var button=document.getElementById(buttonId);
	if (button)
		\{
		if (button.childNodes[0])
			\{
			button.childNodes[0].nodeValue=text;
			}
		else if (button.value)
			\{
			button.value=text;
			}
		else //if (button.innerHTML)
			\{
			button.innerHTML=text;
			}
		}
	}
}

function toggleList_{$class}(tree_id, head_id) 
\{
if (document.getElementById) 
	\{
	var element = document.getElementById(tree_id);
	if (element) 
		\{
		if (element.style.display == 'none') 
			\{
			element.style.display = 'block';
			element = document.getElementById(head_id);
			element.style.color = '' ;
			element.style.backgroundColor = '' ;
			}
		else
			\{
			element.style.display = 'none';
			element = document.getElementById(head_id);
			element.style.color = 'magenta' ;
			element.style.backgroundColor = '' ;
			}
		}
	}
else if (document.all) 
	\{
	var element = document.all[tree_id];
	
	if (element) 
		\{
		if (element.style.display == 'none') 
			\{
			element.style.display = 'block';
			}
		else
			\{
			element.style.display = 'none';
			}
		}
	}
else if (document.layers) 
	\{
	var element = document.layers[tree_id];
	
	if (element) 
		\{
		if (element.display == 'none') 
			\{
			element.display = 'block';
			}
		else
			\{
			element.display = 'none';
			}
		}
	}
} 

</script>
EOS
} 


} # role


