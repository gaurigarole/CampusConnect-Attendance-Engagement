import { LightningElement, api, track } from 'lwc';

const STORAGE_KEY = 'CampusConnectQuickNotes';

export default class QuickNotesLWC extends LightningElement {
    @api label = 'Quick Notes';
    @track notes = '';

    connectedCallback() {
        try {
            const saved = window.localStorage.getItem(STORAGE_KEY);
            if (saved) this.notes = saved;
        } catch (e) {
            // Ignore storage errors
        }
    }

    handleChange(event) {
        this.notes = event.target.value;
    }

    saveNotes() {
        try {
            window.localStorage.setItem(STORAGE_KEY, this.notes || '');
        } catch (e) {}
    }

    clearNotes() {
        this.notes = '';
        this.saveNotes();
    }
}
