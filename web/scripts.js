function addStr(str, index, stringToAdd){
	return str.substring(0, index) + stringToAdd + str.substring(index, str.length);
}

var isTimerOn = false;
var lastTime;

window.addEventListener('message', function(event) {
	item = event.data;
	switch (event.data.action) {
		case 'openCraft':
			var craft = event.data.craft;
			var num = craft.length;
			var paragraph = '';
			var row = '<div class="row">';
			var lastRowNum = 0;
			var job = event.data.job;
			var added = 0

			for(var i = 0; i < num; i++) {
				for(var i1 = 0; i1 < craft[i].job.length; i1++){
					if(craft[i].job[i1] == job || craft[i].job[i1] == ''){
						var itemName = event.data.itemNames;
						var itemId = craft[i].item;
						added++
						row += `
							<div class="col-md-3">
								<div class="card item-card" id="${itemId}wb_${event.data.wb}">
									<div class="card-body item-card-body d-flex justify-content-center align-items-center" style="background-color: rgba(220, 220, 220, 0.20)" id="selected${itemId}wb_${event.data.wb}">
										<span class="item-title text-center">${itemName[itemId]}</span>
										<img src="icons/${itemId}.png" class="image">
									</div>
								</div>
							</div>
						`;
						var myEle = document.getElementById(itemId+"wb_"+event.data.wb);
					if(!myEle) {
						$(document).on('click', "#"+itemId+"wb_"+event.data.wb, function() {
							allID = this.id;
							id = allID.substring(0, allID.indexOf('wb_'));
							$('.item-card-body').css('background-color', 'rgba(220, 220, 220, 0.20)');
							$('#selected'+this.id).css('background-color', 'rgba(31, 94, 255, 1)');
							var sound = new Audio('click.mp3');
							sound.volume = 0.3;
							sound.play();
							$.post('https://okokCrafting/action', JSON.stringify({
								action: "craft",
								item: id,
								crafts: craft,
								itemName: itemName,
							}));
						});
					}

					if ((added) % 4 === 0) {
							row = addStr(row, row.length, `</div><div class="row mt-4">`);
							lastRowNum = row.length+6;
						}
					}
				}
			}
			row += `</div>`;
			
			$('#craft-table').html(row);
			$('.title-name').html(event.data.name);

			$('.title').fadeIn();
			$('.itemslist').fadeIn();
			$('.crafting-body').fadeIn();
		break
	case 'openSideCraft':
		var canCraft = true
		var num = event.data.recipe.length;
		var recipe = ``;
		var img = `
			<img src="icons/${event.data.itemNameID}.png" class="image_itemselected">
			<span style="color: #fff; font-weight: 600; font-size: 20px;" class="ms-2">${event.data.itemName} x${event.data.itemAmount}</span>
		`;

		$('#side-image').html(img);
		$('#craft-time').html(event.data.time);

		for(var i = 0; i < num; i++){
			var idName = event.data.recipe[i][0];
			if (event.data.recipe[i][2]){
				recipe += `
					<div class="d-flex align-items-center mx-1">
						<img src="icons/${event.data.recipe[i][0]}.png" class="image_components">
						<span style="color: #fff; font-weight: 600; font-size: 20px;" class="ms-2">${event.data.itemNames[idName]} x${event.data.recipe[i][1]} (${event.data.inventory[i].key})</span>
					</div>
				`;
			} else {
				recipe += `
					<div class="d-flex align-items-center mx-1">
						<img src="icons/${event.data.recipe[i][0]}.png" class="image_components">
						<span style="color: #fff; font-weight: 600; font-size: 20px;" class="ms-2">${event.data.itemNames[idName]} x${event.data.recipe[i][1]} (${event.data.inventory[i].key})</span>
					</div>
				`;
			}
			

			if(event.data.recipe[i][1] > event.data.inventory[i].key){
				canCraft = false
			}
		}

		if(canCraft) {
			$('#craft-button-div').html(`
				<button type="button" id="craft-button" data-item="${event.data.itemNameID}" data-recipe="${event.data.recipe}" data-amount="${event.data.itemAmount}" onclick="craft(this)" class="btn btn-blue flex-grow-1 mt-2" style="border-radius: 10px; flex-basis: 100%; width: 100%; font-weight: 600;"><i class="fas fa-pencil-ruler"></i> CRAFT [${event.data.itemName}]</button>
			`);
			$('#craft-button').fadeIn();
		} else {
			$('#craft-button').fadeOut();
		}

		$('#craft-percentage').html(event.data.percentage);
		$('.components-responsive').html(recipe);

		$('.itemrequirements').fadeIn();
		break
	case 'ShowCraftCount':
		var time = event.data.time;
		var itemName = event.data.name;
		
		$('#crafting-text').html(`Crafting`);
		$('#item-name').html(`${itemName}`);
		$('#item-timer').html(`${time}s`);
		if(time == lastTime) {
			$('#cog').removeClass('fa-spin');
		} else {
			$('#cog').addClass('fa-spin');
		}
		

		if(!isTimerOn){
			isTimerOn = true;
			$('.timer').fadeIn();
		}
		lastTime = time
		break
	case 'CompleteCraftCount':
		var itemName = event.data.name;

		$('.timer-card-body').css('background-color', '#1fa34a');
		$('#crafting-text').html(`Crafted`);
		$('#item-name').html(`${itemName}`);
		$('#item-timer').html(`0s`);

		$('#cog').removeClass('fa-spin');
		$('#cog').removeClass('fa-cog');

		$('#cog').addClass('fa-check');
		
		break
	case 'FailedCraftCount':
		var itemName = event.data.name;

		$('.timer-card-body').css('background-color', '#990b0b');
		$('#crafting-text').html(`Failed to craft`);
		$('#item-name').html(`${itemName}`);
		$('#item-timer').html(`0s`);

		$('#cog').removeClass('fa-spin');
		$('#cog').removeClass('fa-cog');

		$('#cog').addClass('fa-times');
		
		break
	case 'HideCraftCount':
		isTimerOn = false;
		$('.timer').fadeOut();
		setTimeout(function(){
			$('#cog').removeClass('fa-times');
			$('#cog').removeClass('fa-check');
			$('#cog').addClass('fa-spin');
			$('#cog').addClass('fa-cog');

			$('.timer-card-body').css('background-color', 'rgba(31, 94, 255, 1)');
		}, 400);
		break
	}
});

$(document).ready(function() {
	document.onkeyup = function(data) {
		if (data.which == 27) {
			$('.crafting-body').fadeOut();
			$('.title').fadeOut();
			$('.itemslist').fadeOut();
			$('.itemrequirements').fadeOut();
			$.post('https://okokCrafting/action', JSON.stringify({
				action: "close",
			}));
		}
	};
});

function craft(t) {
	var itemId = t.dataset.item;
	var recipe = t.dataset.recipe;
	var amount = t.dataset.amount;

	$.post('https://okokCrafting/action', JSON.stringify({
		action: "craft-button",
		itemID: itemId,
		recipe: recipe,
		amount: amount,
	}));
}