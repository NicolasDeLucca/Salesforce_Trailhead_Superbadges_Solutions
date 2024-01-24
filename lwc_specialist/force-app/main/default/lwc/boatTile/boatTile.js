import { LightningElement, api } from 'lwc';

// style properties
const BACKGROUND_IMAGE_PARAMETER = 'background-image';
const TILE_CLASS = 'tile-wrapper';
const SELECTED = 'selected';

export default class BoatTile extends LightningElement
{
  @api
  boat;
  
  @api
  selectedBoatId;

  get backgroundStyle()
  { 
    picture = this.boat.Picture__c;
    return `${this.backgroundImage(picture)}`;
  }
  
  get tileClass()
  { 
    tileClass = TILE_CLASS;

    if (this.boat.Id == this.selectedBoatId)
       tileClass += `${SELECTED}`;

    return tileClass;
  }
  
  selectBoat()
  { 
    this.selectedBoatId = this.boat.Id;
    const boatselect  = new CustomEvent('boatselect', 
    {
      detail:
      {
        boatId: this.selectedBoatId
      }
    });
    
    this.dispatchEvent(boatselect);
  }

  // helper methods

  backgroundImage(url)
  {
    return BACKGROUND_IMAGE_PARAMETER + ':url(' + `${url}` + ')';
  }
}
