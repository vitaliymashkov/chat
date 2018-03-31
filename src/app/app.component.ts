import { Component } from '@angular/core';
import {VERSION} from '../version';

@Component({
    selector: 'my-app',
    templateUrl: './views/app.component.html',
    styleUrls: ['./styles/app.component.css']
})
export class AppComponent {
    version= VERSION;
    name= 'TESTING12312';
    count: number=0;
    increase() : void {
        this.count++;
    }
}