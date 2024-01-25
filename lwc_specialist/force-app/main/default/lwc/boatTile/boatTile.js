import { LightningElement, api } from 'lwc';

const SELECTED_TILE_WRAPPER = 'tile-wrapper selected';
const UNSELECTED_TILE_WRAPPER = 'tile-wrapper';

export default class BoatTile extends LightningElement
{
  @api
  boat;
  
  @api
  selectedBoatId;

  get backgroundStyle()
  { 
     return 'background-image:url(' + `${this.boat.Picture__c}` + ')';
  }
  
  get tileClass()
  { 
    if (this.boat.Id == this.selectedBoatId)
       return SELECTED_TILE_WRAPPER;

    return UNSELECTED_TILE_WRAPPER;
  }
  
  selectBoat()
  { 
    this.selectedBoatId = this.boat.Id;
    
    const boatselect = new CustomEvent('boatselect', 
    {
      detail: { boatId: this.boat.Id },
    });
    
    this.dispatchEvent(boatselect);
  }
}
