#include "AdaBoost.h"
#include <iostream>
using std::cout;

vector<matched_patch> block_match(const Mat& image, int patchNum, const Mat& patch, int rstep, int cstep) {

	//���룺ȫ��ͼ��image��ƥ������ĿpatchNum���ο���patch
	//���������patchNum��matched_patch��vector


	//ȫ��ͼ�����ƥ���ĳߴ�
	int prs = patch.size().height, pcs = patch.size().width;
	int rs = image.size().height, cs = image.size().width;

	//Ϊ�˼��٣���ƥ����ȫ�ֵĲ���Ϊ�������С��һ��
	int rbnd = rs - prs + 1, cbnd = cs - pcs + 1;	//������߽�

	int vec_size = ((rs - prs) / rstep + 1)*((cs - pcs) / cstep + 1);
	//��Ż������������е�patch��Ϣ
	vector<matched_patch> sp(vec_size);

	int index = 0;
	//�������������
	for (int i = 0; i < rbnd; i+=rstep) {
		for (int j = 0; j < cbnd; j+=cstep) {
			sp[index].xpos = i; sp[index].ypos = j;
			sp[index].distance = cv::norm(patch - image(cv::Rect(i, j, prs, pcs)))/(prs*pcs);
			++index;
		}
	}
	std::sort(sp.begin(), sp.end());

	//ȡ������С��patchNum��
	vector<matched_patch> mps = vector<matched_patch>(sp.begin(), sp.begin() + patchNum);

	return mps;
}

Mat group(const Mat& image, const vector<matched_patch>& mp, int prs, int pcs) {

	//���룺ȫ��ͼ��image, ����ƥ�����Ϣ��vector;mp, ƥ���ĳߴ�prs��pcs
	//���������ƥ�����ɵľ���patch_group��ÿ��ƥ��鰴�����ӳ���������
	int rows = prs*pcs, cols = mp.size();
	Mat patch_group(rows, cols, CV_64F);
	for (int i = 0; i != cols; ++i) {
		image(cv::Rect(mp[i].xpos, mp[i].ypos, prs, pcs)).clone().reshape(0, rows).copyTo(patch_group.col(i));	//image(Range)ֻ�Ǵ�����ROI��һ�����ã����뽫��cloneһ��
	}
	return patch_group;
}

Mat solve_wnnm(const Mat& pg, double noise_var, double c, double eps) {

	//���룺����ƥ�����ɵľ���pg�� ��������nvar�� ����c�� ��ֹ������Ĳ���eps
	//�����wnnm�������Ƴ��ľ���

	//����ת������Ϊ����ֵ�ֽ����ָ�����
	int rows = pg.size().height, cols = pg.size().width;
	Mat U, S, Vt;
	cv::SVD::compute(pg, S, U, Vt, cv::SVD::FULL_UV);	//��U��V������Ͼ���Ĭ������²���
	//S�Ѿ�������ֵ��ɵ�������

	//���Ƹɾ�patch������ֵ����
	Mat sigma_est = S.clone();
	int patchNum = cols;
	double nvar = noise_var / 255.0;	//��Ӧ�أ����������һ����[0, 1]
	for (double &p : cv::Mat_<double>(sigma_est)) {
		double temp = sqrt(MAX(p*p - patchNum*nvar, 0));
		p = temp;
	}//��Ҫʹ�����������Ľ��ٶȣ���

	 //Ȩֵ����
	Mat weight = sigma_est.clone();
	for (double &p : cv::Mat_<double>(weight)) {
		double temp = c*sqrt(patchNum) / (p + eps);
		p = temp;
	}//��Ҫʹ�����������Ľ��ٶȣ���

	 //�����о��������
	Mat Sw_diag = S - weight;
	for (double &p : cv::Mat_<double>(Sw_diag)) {
		double temp = MAX(p, 0);
		p = temp;
	}//��Ҫʹ�����������Ľ��ٶȣ���
	Mat Sw = Mat(rows, cols, CV_64F, cv::Scalar(0));

	for (int i = 0; i != cols; ++i) Sw.at<double>(i, i) = Sw_diag.at<double>(i);

	return U*Sw*Vt;

}

Mat aggregate(const Mat& dist, const Mat& est, double h, int prs) {	//�ú�����Ҫʹ�����������Ľ��ٶȣ���

	//���룺dist��block_match���ص�vectorԪ�ص�distance��ɵ�Mat����Ҫ��ʽת��
	//		wnnm���Ƴ��ľ���est�����ھۺϵĲ���h
	//�����ȥ����patch:deno_patch

	//����Ȩֵ
	Mat weight = dist.clone();	//Ϊ�������㣬����Ҫ��dist��weight����������
	double sum = 0;
	for (double &p : cv::Mat_<double>(weight)) {
		double temp = exp(-p*p / h);
		sum += temp;
		p = temp;
	}//��Ҫʹ�����������Ľ��ٶȣ���

	for (double &p : cv::Mat_<double>(weight)) {
		double temp = p / sum;
		p = temp;
	}//��Ҫʹ�����������Ľ��ٶȣ���

	 //��һ���Ǿ�������Ľ������������֤
	Mat deno_vec = est*weight;
	return deno_vec.reshape(0, prs);	//����ȥ���Ŀ飨ע���ǿ飡������Χ[0, 1]
}

double cal_rhoK(const Mat& prim_patch, const Mat& deno_patch, double c, double noise_var) {

	//����:�ʼδȥ��ͼ���ж�Ӧ��patch��prim_patch�� ȥ����deno_patch�����ڲ���c
	//���������ϵ��rhoK

	double dp_norm = cv::norm(deno_patch);
	Mat diff = prim_patch - deno_patch;

	diff.reshape(0, 1);// ��diffתΪ������������cal_var�ļ���
	double nvar = noise_var / 255.0;
	double resi_en = c*abs(nvar - cal_var(diff));
	double rhoK = dp_norm / (dp_norm + sqrt(MAX(dp_norm*dp_norm - resi_en, 0)));
	return rhoK;
}

double cal_var(const Mat& m) {

	//˵�����������Ԫ�ط����С����
	//Ҫ��m����/������

	int elem_num = m.size().height;	//����Ԫ�ظ���
	double mean = m.dot(Mat::ones(m.size(), m.type())) / elem_num;
	return (m.dot(m) - elem_num*mean*mean) / (elem_num - 1);

}