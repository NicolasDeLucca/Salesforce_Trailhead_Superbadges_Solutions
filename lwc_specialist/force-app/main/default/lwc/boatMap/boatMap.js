import BOATMC from '@salesforce/messageChannel/BoatMessageChannel__c';
import { getRecord } from 'lightning/uiRecordApi';
import { subscribe, APPLICATION_SCOPE, MessageContext } from 'lightning/messageService';
import { wire, api, LightningElement } from 'lwc';

const LONGITUDE_FIELD = 'Boat__c.Geolocation__Longitude__s';
const LATITUDE_FIELD = 'Boat__c.Geolocation__Latitude__s';
const BOAT_FIELDS = [LONGITUDE_FIELD, LATITUDE_FIELD];  

export default class BoatMap extends LightningElement
{
  subscription = null;
  boatId;

  @api
  get recordId()
  {
    return this.boatId;
  }

  set recordId(value)
  {
    this.setAttribute('boatId', value);
    this.boatId = value;
  }

  get showMap()
  {
     return this.mapMarkers.length > 0;
  }

  error = undefined;
  mapMarkers = [];

  // message service
  @wire(MessageContext)
  messageContext;
  // subscribes to the message channel
  subscribeMC()
  {
    if (this.subscription || this.recordId)
      return;

    this.subscription = subscribe(
      this.messageContext,
      BOATMC,
      (message) => { this.boatId = message.recordId },
      { scope: APPLICATION_SCOPE }
    );
  }

  connectedCallback()
  {
     this.subscribeMC();
  }

  @wire(getRecord, {recordId: '$boatId', fields: BOAT_FIELDS})
  wiredRecord({ error, data })
  {
    if (data)
    {
      this.error = undefined;
      const longitude = data.fields.Geolocation__Longitude__s.value;
      const latitude = data.fields.Geolocation__Latitude__s.value;
      this.updateMap(longitude, latitude);
    } 
    else if (error)
    {
      this.error = error;
      this.boatId = undefined;
      this.mapMarkers = [];
    }
  }

  updateMap(Longitude, Latitude)
  {
    currentBoatLocation = { Longitude, Latitude };
    this.mapMarkers = 
    [
      {location: currentBoatLocation}
    ];
  }
}