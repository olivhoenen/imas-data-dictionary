
function ToggleErrorDisplay(selector) {
    $(selector).toggleClass('hide-error');
}

const _base =[];
function makeTree(selector){

    const collection = {
        root:{                        
            children: []
        }
    };
    const $table = $(selector);
    const rTestError = /_error/;
    const rSplit = /(.+)\.([^\.]+)$/;
    const rSlash = /\//g;
	const $tr = $table.find('>tbody>tr');

    $table.addClass('hide-error');
	$tr.each(function(index, row) {
		const $row = $(row);
		const $tdFirst = $row.find('>td:first');
		const fullPath = $tdFirst.text().replace(rSlash, '.');
		const res = fullPath.match(rSplit);
		const entry = collection[fullPath]= {

		};
		$row.attr("data-tt-id",fullPath);
		// si res est null, il n'y a pas de parent
		if (res === null){
			collection.root.children.push(entry);
		}
		else{
			const parent = collection[res[1]];
			$tdFirst.text(res[2]);
			$row.attr("data-tt-parent-id", res[1]);
			if (typeof parent.children === "undefined"){
				$(parent.elem).addClass('selected');               
				parent.children = [];
			}
				
			parent.children.push(entry);
			if (rTestError.test(res[2])) {
				
				$row.addClass('error-elem');
			}
		}
		collection[fullPath]= {
			elem: row
		};
	});
	$table.treetable({
	expandable: true , 
	clickableNodeNames: true, 
	indent: 19, 
	indenterTemplate: '<span class="indenter" ><a href="#" title="Collapse">&nbsp;</a></span>'
	});
}




