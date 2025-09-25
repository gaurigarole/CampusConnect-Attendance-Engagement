import { LightningElement, wire, track } from 'lwc';
import getAttendanceDistribution from '@salesforce/apex/StudentController.getAttendanceDistribution';

export default class AttendanceDistributionLWC extends LightningElement {
    @track data = { regular: 0, atRisk: 0, probation: 0 };
    @track total = 0;
    @track error;

    @wire(getAttendanceDistribution)
    wired({ error, data }) {
        if (data) {
            const regular = data['Regular'] || 0;
            const atRisk = data['At Risk'] || 0;
            const probation = data['Probation'] || 0;
            const total = regular + atRisk + probation;
            this.data = { regular, atRisk, probation };
            this.total = total;
            this.error = undefined;
        } else if (error) {
            this.error = error;
        }
    }

    get regularPct() { return this.toPct(this.data.regular); }
    get atRiskPct() { return this.toPct(this.data.atRisk); }
    get probationPct() { return this.toPct(this.data.probation); }

    toPct(value) {
        if (!this.total) return 0;
        return Math.round((value / this.total) * 100);
    }
}
