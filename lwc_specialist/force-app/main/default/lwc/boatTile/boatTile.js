import { LightningElement, api } from 'lwc';

//css properties
const BACKGROUND_IMAGE_PARAMETER = 'background-image';
const TILE_CLASS = 'tile-wrapper';
const SELECTED = 'selected';

export default class BoatTile extends LightningElement
{
  @api
  boat;
  
  @api
  selectedBoatId;
  
  // Getter for dynamically setting the background image for the picture
  get backgroundStyle()
  { 
     picture = this.boat.Picture__c;
     return '' + getBackgroundImage(picture);
  }
  
  // Getter for dynamically setting the tile class based on whether the
  // current boat is selected
  get tileClass()
  { 
    tileClass = TILE_CLASS;

    if (this.boat.Id == this.selectedBoatId)
      tileClass + ' ' + SELECTED;

    return tileClass;
  }
  
  // Fires event with the Id of the boat that has been selected.
  selectBoat()
  { 
    this.selectedBoatId = this.boat.Id;
    const boatselect = new CustomEvent('boatselect', 
    {
      detail:
      {
          boatId: this.selectedBoatId
      }
    });
    
    this.dispatchEvent(boatselect);
  }

  // helper methods

  getBackgroundImage(url)
  {
     return BACKGROUND_IMAGE_PARAMETER + `:` + `url( ${url} )`;
  }
}
