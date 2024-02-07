import { LightningElement, api } from 'lwc';
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
import { loadStyle, loadScript } from 'lightning/platformResourceLoader';
import fivestar from '@salesforce/resourceUrl/fivestar'

const ERROR_TITLE = 'Error loading five-star';
const ERROR_VARIANT = 'error';
const EDITABLE_CLASS = 'c-rating';
const READ_ONLY_CLASS = 'readonly c-rating';

export default class FiveStarRating extends LightningElement
{
  @api
  readOnly;
  @api
  value;

  editedValue;
  isRendered;

  get starClass()
  {
    star = this.readOnly ? READ_ONLY_CLASS : 
      EDITABLE_CLASS;

    return star;
  }

  renderedCallback()
  {
    if (this.isRendered)
      return;

    this.loadScript();
    this.isRendered = true;
  }

  loadScript()
  {
    Promise.all(
    [
      loadScript(this, fivestar + '/rating.js'),
      loadStyle(this, fivestar + '/rating.css')
    ])
    .then(() =>
    {
      this.initializeRating();
    })
    .catch(error => 
    {
      const toastEvent = new ShowToastEvent(
      {
          title: ERROR_TITLE,
          message: error.message,
          variant: ERROR_VARIANT,
      });
      this.dispatchEvent(toastEvent);
    });
  }

  initializeRating()
  {
    let domEl = this.template.querySelector('ul');
    let maxRating = 5;
    let self = this;

    let callback = function(rating)
    {
      self.editedValue = rating;
      self.ratingChanged(rating);
    };

    this.ratingObj = window.rating(
      domEl,
      this.value,
      maxRating,
      callback,
      this.readOnly
    );
  }

  ratingChanged(rating)
  {
    if (rating)
    {
      const ratingChangeEvent = new CustomEvent('ratingchange', 
      {
        detail: 
        { 
          rating: rating 
        }
      });

      this.dispatchEvent(ratingChangeEvent);
    }
  }
}