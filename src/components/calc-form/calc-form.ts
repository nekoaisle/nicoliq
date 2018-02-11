import { Component } from '@angular/core';
import {  
  FormBuilder,  
  FormGroup,  
  Validators,  
  AbstractControl  
} from '@angular/forms';

@Component({
  selector: 'calc-form',
  templateUrl: 'calc-form.html'
})
export class CalcFormComponent {

  form: FormGroup;
  flavor_ml: AbstractControl;   // フレーバー量
  nico_c: AbstractControl;      // ニコチン原液濃度
  liq_c: AbstractControl;       // ニコリキ濃度

  nico_ml: string;              // ニコチン原液量
  liq_ml: string;               // ニコリキ量

  constructor(fb: FormBuilder) {
    console.log('Hello CalcFormComponent Component');

    // フォームの構築
    this.form = fb.group({
      'flavor_ml': ["", Validators.required],  // フレーバー量
      'nico_c'  : ["", Validators.required],  // ニコチン原液濃度
      'liq_c'   : ["", Validators.required],  // ニコリキ原液濃度
    });

    this.flavor_ml = this.form.controls['flavor_ml'];  
    this.nico_c = this.form.controls['nico_c'];  
    this.liq_c = this.form.controls['liq_c'];  
  }

  onSubmit(value: string): void {
    console.log('送信された値：', value);
    // フレーバー量
    let fl = parseFloat(this.flavor_ml.value);
    // ニコチン原液量
    let nr = parseFloat(this.nico_c.value);
    // 作成したいニコチン濃度
    let tr = parseFloat(this.liq_c.value);

    // ニコチンリキッド量
    let nl = fl * tr / (nr - tr);

    this.liq_ml = "" +  ((nl * nr) / tr).toFixed(1);
    this.nico_ml = nl.toFixed(1);
  }
}

