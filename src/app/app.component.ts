import { Component } from '@angular/core';

@Component({
    selector: 'my-app',
    templateUrl: './views/app.component.html',
    styleUrls: ['./styles/app.component.css']
})
export class AppComponent {
    name= '';
    count: number=0;
    increase() : void {
        this.count++;
    }
}